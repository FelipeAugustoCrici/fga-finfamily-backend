import { prisma } from '@/lib/prisma'
import { CreditCardsRepository } from './credit-cards.repository'
import { CreateCreditCardInput } from './dtos/create-credit-card.schema'
import { CreatePurchaseInput } from './dtos/create-purchase.schema'
import { PersonsService } from '@/modules/persons/persons.service'
import { FamiliesService } from '@/modules/families/families.service'

export class CreditCardsService {
  private repo = new CreditCardsRepository()
  private personsService = new PersonsService()
  private familiesService = new FamiliesService()

  async createCreditCard(data: CreateCreditCardInput) {
    return this.repo.createCreditCard(data)
  }

  async listCreditCards(familyId?: string) {
    return this.repo.getCreditCards(familyId)
  }

  async getCreditCardById(id: string) {
    return this.repo.getCreditCardById(id)
  }

  async updateCreditCard(id: string, data: Partial<CreateCreditCardInput>) {
    return this.repo.updateCreditCard(id, data)
  }

  async deleteCreditCard(id: string) {
    return this.repo.deleteCreditCard(id)
  }

  // ─── Purchases ────────────────────────────────────────────────────────────

  /**
   * Cria uma compra no cartão, gera as parcelas nas faturas corretas e,
   * quando há um responsável (ownerId) com família resolvida, cria também
   * um Expense por parcela — para a compra entrar no saldo, no calendário
   * e nos resumos, junto com os lançamentos normais. Sem ownerId, a compra
   * é registrada apenas no módulo de cartões (comportamento legado).
   */
  async createPurchase(
    input: CreatePurchaseInput,
    userId?: string,
  ) {
    const card = await this.repo.getCreditCardById(input.creditCardId)
    if (!card || !card.isActive) {
      throw new Error('Cartão não encontrado ou inativo')
    }

    if (input.totalAmount > card.availableLimit) {
      throw new Error('Limite de crédito insuficiente para esta compra')
    }

    let familyId = input.familyId
    if (input.ownerId) {
      if (userId) {
        const belongs = await this.personsService.validatePersonBelongsToUserFamily(
          input.ownerId,
          userId,
        )
        if (!belongs) {
          throw new Error('Responsável não pertence à sua família')
        }
      }

      const owner = await this.personsService.getPersonWithFamily(input.ownerId)
      if (!owner) throw new Error('Responsável inválido')
      familyId = familyId || owner.familyId || undefined

      if (card.familyId && familyId && card.familyId !== familyId) {
        throw new Error('Este cartão não pertence à família do responsável selecionado')
      }
    }

    // Parse manual dos componentes (ano-mês-dia) em vez de `new Date(string)`:
    // uma string de data pura ("2026-09-22") é interpretada como meia-noite
    // UTC pelo JS, e os getters usados abaixo (getDate/getMonth/getFullYear)
    // são no fuso local do processo — em qualquer fuso atrás de UTC isso
    // volta um dia. Mesmo padrão já usado em ExpensesService.createExpense.
    const [py, pm, pd] = input.purchaseDate.split('T')[0].split('-').map(Number)
    const purchaseDate = new Date(py, pm - 1, pd)
    const installmentAmount = Number((input.totalAmount / input.installments).toFixed(2))
    const categoryName =
      input.categoryName || (await this.resolveCategoryName(input.categoryId))

    const purchase = await prisma.$transaction(async (tx) => {
      const created = await tx.creditCardPurchase.create({
        data: {
          creditCardId: input.creditCardId,
          familyId,
          ownerId: input.ownerId,
          categoryId: input.categoryId,
          description: input.description,
          purchaseDate,
          totalAmount: input.totalAmount,
          installments: input.installments,
          observation: input.observation,
        },
      })

      // Gerar parcelas e vincular às faturas corretas
      let remaining = input.totalAmount
      for (let i = 0; i < input.installments; i++) {
        const isLast = i === input.installments - 1
        const amount = isLast ? Number(remaining.toFixed(2)) : installmentAmount
        remaining = Number((remaining - amount).toFixed(2))

        const { invoiceMonth, invoiceYear, closingDate, dueDate } = this.resolveInvoicePeriod(
          purchaseDate,
          card.closingDay,
          card.dueDay,
          i,
        )
        // Data "de exibição" da parcela nos lançamentos: mês da compra + i meses
        // (parcela 1 no mês comprado, parcela 2 no mês seguinte, ...). Independe
        // de quando a fatura realmente fecha/vence — isso continua controlado
        // por invoiceMonth/invoiceYear/dueDate acima, usado só para a fatura e o limite.
        const listingDate = this.addMonthsClamped(purchaseDate, i)

        let invoice = await tx.creditCardInvoice.findUnique({
          where: {
            creditCardId_referenceMonth_referenceYear: {
              creditCardId: input.creditCardId,
              referenceMonth: invoiceMonth,
              referenceYear: invoiceYear,
            },
          },
        })
        if (!invoice) {
          invoice = await tx.creditCardInvoice.create({
            data: {
              creditCardId: input.creditCardId,
              referenceMonth: invoiceMonth,
              referenceYear: invoiceYear,
              closingDate,
              dueDate,
              totalAmount: 0,
              paidAmount: 0,
              status: 'open',
            },
          })
        }

        const installment = await tx.creditCardInstallment.create({
          data: {
            purchaseId: created.id,
            invoiceId: invoice.id,
            installmentNumber: i + 1,
            totalInstallments: input.installments,
            amount,
            referenceMonth: invoiceMonth,
            referenceYear: invoiceYear,
          },
        })

        await tx.creditCardInvoice.update({
          where: { id: invoice.id },
          data: { totalAmount: { increment: amount } },
        })

        if (input.ownerId && familyId) {
          // Registro da compra em si: já nasce PAGO — pagar no cartão quita a
          // dívida com quem vendeu na hora. O que falta pagar é a fatura,
          // representada por um lançamento agregado separado (abaixo).
          await tx.expense.create({
            data: {
              description:
                input.installments > 1
                  ? `${input.description} (${i + 1}/${input.installments})`
                  : input.description,
              value: amount,
              categoryName,
              categoryId: input.categoryId,
              type: 'variable',
              date: listingDate,
              month: listingDate.getMonth() + 1,
              year: listingDate.getFullYear(),
              paymentMethod: 'credit_card',
              isCreditCard: true,
              creditCardId: input.creditCardId,
              purchaseId: created.id,
              installmentId: installment.id,
              personId: input.ownerId,
              status: 'PAID',
              paidAmount: amount,
              isShared: input.isShared ?? true,
            },
          })

          // Lançamento da fatura: um por cartão+mês de vencimento, agregando
          // todas as parcelas que caem nela. Nasce/permanece PENDING até o
          // usuário pagar a fatura (aqui ou na tela de Cartões).
          const existingInvoiceExpense = await tx.expense.findUnique({
            where: { creditCardInvoiceId: invoice.id },
          })
          if (existingInvoiceExpense) {
            await tx.expense.update({
              where: { id: existingInvoiceExpense.id },
              data: { value: { increment: amount } },
            })
          } else {
            await tx.expense.create({
              data: {
                description: `Fatura ${card.name} — ${String(invoiceMonth).padStart(2, '0')}/${invoiceYear}`,
                value: amount,
                categoryName: 'Cartão de crédito',
                type: 'variable',
                date: dueDate,
                month: invoiceMonth,
                year: invoiceYear,
                paymentMethod: 'credit_card',
                isCreditCard: true,
                creditCardId: input.creditCardId,
                creditCardInvoiceId: invoice.id,
                personId: input.ownerId,
                status: 'PENDING',
                isShared: input.isShared ?? true,
              },
            })
          }
        }
      }

      // Reduzir limite disponível
      await tx.creditCard.update({
        where: { id: input.creditCardId },
        data: { availableLimit: { decrement: input.totalAmount } },
      })

      return created
    })

    return purchase
  }

  /**
   * Exclui uma compra e todas as suas parcelas: remove os Expenses vinculados
   * (soft delete), retira o valor das faturas ainda abertas e recompõe o
   * limite. Bloqueada quando qualquer fatura envolvida já foi paga.
   */
  async deletePurchase(purchaseId: string, userId: string) {
    const purchase = await prisma.creditCardPurchase.findUnique({
      where: { id: purchaseId },
      include: { parcels: { include: { invoice: true } } },
    })
    if (!purchase) throw new Error('Compra não encontrada')

    if (purchase.ownerId) {
      const belongs = await this.personsService.validatePersonBelongsToUserFamily(
        purchase.ownerId,
        userId,
      )
      if (!belongs) throw new Error('Acesso negado')
    } else if (purchase.familyId) {
      const family = await this.familiesService.getFamily(purchase.familyId, userId)
      if (!family) throw new Error('Acesso negado')
    } else {
      throw new Error('Acesso negado')
    }

    const hasPaidInvoice = purchase.parcels.some((p) => p.invoice.status === 'paid')
    if (hasPaidInvoice) {
      throw new Error(
        'Não é possível excluir uma compra com fatura já paga. Estorne o pagamento antes.',
      )
    }

    await prisma.$transaction(async (tx) => {
      await tx.expense.updateMany({
        where: { purchaseId },
        data: { is_deleted: true, dt_deleted: new Date() },
      })

      const invoiceDeltas = new Map<string, number>()
      for (const p of purchase.parcels) {
        invoiceDeltas.set(p.invoiceId, (invoiceDeltas.get(p.invoiceId) || 0) + p.amount)
      }
      for (const [invoiceId, amount] of invoiceDeltas) {
        const updatedInvoice = await tx.creditCardInvoice.update({
          where: { id: invoiceId },
          data: { totalAmount: { decrement: amount } },
        })

        // Ajusta o lançamento agregado da fatura: reduz o valor, ou remove
        // se a fatura ficou sem nenhuma parcela.
        const invoiceExpense = await tx.expense.findUnique({ where: { creditCardInvoiceId: invoiceId } })
        if (invoiceExpense) {
          if (updatedInvoice.totalAmount <= 0.001) {
            await tx.expense.delete({ where: { id: invoiceExpense.id } })
          } else {
            await tx.expense.update({
              where: { id: invoiceExpense.id },
              data: { value: { decrement: amount } },
            })
          }
        }
      }

      await tx.creditCardInstallment.deleteMany({ where: { purchaseId } })
      await tx.creditCardPurchase.delete({ where: { id: purchaseId } })
      await tx.creditCard.update({
        where: { id: purchase.creditCardId },
        data: { availableLimit: { increment: purchase.totalAmount } },
      })
    })

    return { success: true }
  }

  async getPurchasesByCard(creditCardId: string) {
    return this.repo.getPurchasesByCard(creditCardId)
  }

  // ─── Invoices ─────────────────────────────────────────────────────────────

  async getInvoices(creditCardId: string) {
    return this.repo.getInvoices(creditCardId)
  }

  async getInvoiceById(id: string) {
    return this.repo.getInvoiceById(id)
  }

  async payInvoice(invoiceId: string, paidAmount: number) {
    const invoice = await this.repo.getInvoiceById(invoiceId)
    if (!invoice) throw new Error('Fatura não encontrada')

    await prisma.$transaction(async (tx) => {
      await tx.creditCardInvoice.update({
        where: { id: invoiceId },
        data: { status: 'paid', paidAmount },
      })

      // As parcelas (Expense com purchaseId) já nascem PAGAS — quem falta
      // marcar como paga é o lançamento agregado da fatura.
      const invoiceExpense = await tx.expense.findUnique({ where: { creditCardInvoiceId: invoiceId } })
      if (invoiceExpense) {
        await tx.expense.update({
          where: { id: invoiceExpense.id },
          data: { status: 'PAID', paidAmount: invoiceExpense.value },
        })
      }
    })

    // Recompor limite disponível
    await this.repo.updateAvailableLimit(invoice.creditCardId, paidAmount)

    return { success: true }
  }

  async getAllInvoicesByFamily(familyId: string) {
    return this.repo.getAllInvoicesByFamily(familyId)
  }

  async getCreditCardSummaryByFamily(familyId: string, month: number, year: number) {
    return this.repo.getCreditCardSummaryByFamily(familyId, month, year)
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  private async resolveCategoryName(categoryId?: string): Promise<string> {
    if (!categoryId) return 'Geral'
    const category = await prisma.category.findUnique({ where: { id: categoryId } })
    return category?.name || 'Geral'
  }

  /**
   * Soma `months` meses a uma data, ajustando para o último dia do mês de
   * destino quando o dia original não existir nele (ex.: 31/jan + 1 mês → 28
   * ou 29/fev, em vez do JS rolar para março).
   */
  private addMonthsClamped(date: Date, months: number): Date {
    const targetIndex = date.getMonth() + months
    const year = date.getFullYear() + Math.floor(targetIndex / 12)
    const month = ((targetIndex % 12) + 12) % 12
    const lastDayOfTargetMonth = new Date(year, month + 1, 0).getDate()
    const day = Math.min(date.getDate(), lastDayOfTargetMonth)
    return new Date(year, month, day)
  }

  /**
   * Determina em qual fatura uma parcela deve cair.
   * A compra entra no ciclo que fecha no dia `closingDay`: se a compra for
   * feita até esse dia (inclusive), cai no fechamento deste mês; se for
   * depois, cai no fechamento do mês seguinte. O vencimento fica no mesmo
   * mês do fechamento quando `dueDay` vem depois de `closingDay` no
   * calendário (ex.: fecha dia 1, vence dia 10 → mesmo mês); cai no mês
   * seguinte ao fechamento quando `dueDay` vem antes (ex.: fecha dia 25,
   * vence dia 5). O parâmetro `offset` desloca para parcelas futuras (uma
   * parcela por ciclo).
   */
  private resolveInvoicePeriod(
    purchaseDate: Date,
    closingDay: number,
    dueDay: number,
    offset: number,
  ) {
    const day = purchaseDate.getDate()
    const month = purchaseDate.getMonth() + 1 // 1-12
    const year = purchaseDate.getFullYear()

    let closingMonth = month + (day > closingDay ? 1 : 0) + offset
    let closingYear = year
    while (closingMonth > 12) {
      closingMonth -= 12
      closingYear += 1
    }

    let invoiceMonth = closingMonth + (dueDay > closingDay ? 0 : 1)
    let invoiceYear = closingYear
    while (invoiceMonth > 12) {
      invoiceMonth -= 12
      invoiceYear += 1
    }

    const closingDate = new Date(closingYear, closingMonth - 1, closingDay)
    const dueDate = new Date(invoiceYear, invoiceMonth - 1, dueDay)

    return { invoiceMonth, invoiceYear, closingDate, dueDate }
  }
}
