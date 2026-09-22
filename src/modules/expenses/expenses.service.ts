import { prisma } from '@/lib/prisma'
import { ExpensesRepository } from './expenses.repository'
import { RecurringExpensesRepository } from '@/modules/recurring-expenses/recurring-expenses.repository'
import { RecurringExpensesService } from '@/modules/recurring-expenses/recurring-expenses.service'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { UpdateExpenseInput } from '@/modules/expenses/dtos'
import { FamiliesService } from '@/modules/families/families.service'
import { PersonsService } from '@/modules/persons/persons.service'
import { CreditCardsService } from '@/modules/credit-cards/credit-cards.service'

export class ExpensesService {
  private incomesService: IncomesService = new IncomesService()
  private familiesService: FamiliesService = new FamiliesService()
  private personsService: PersonsService = new PersonsService()
  private creditCardsService: CreditCardsService = new CreditCardsService()
  private recurringExpensesService: RecurringExpensesService = new RecurringExpensesService()
  private repository: ExpensesRepository = new ExpensesRepository()
  private recurringRepository: RecurringExpensesRepository = new RecurringExpensesRepository()

  async createExpense(data: {
    description: string
    value: number
    categoryName: string
    categoryId?: string
    type: string
    date: string
    personId: string
    status?: string
    paymentMethod?: string
    creditCardId?: string
    installments?: number
    isRecurring?: boolean
    durationMonths?: number
    userId: string
    isShared?: boolean
  }) {
    // Validar se a pessoa pertence à família do usuário
    const isValid = await this.personsService.validatePersonBelongsToUserFamily(
      data.personId,
      data.userId,
    )

    if (!isValid) {
      throw new Error('Pessoa inválida ou não pertence à sua família')
    }

    if (data.paymentMethod === 'credit_card') {
      if (data.isRecurring) {
        throw new Error('Lançamentos pagos no cartão de crédito não podem ser recorrentes')
      }
      if (!data.creditCardId) {
        throw new Error('Selecione um cartão de crédito')
      }

      const person = await this.personsService.getPersonWithFamily(data.personId)
      if (!person || !person.familyId) {
        throw new Error('Responsável não possui família associada')
      }

      // Cria a compra, as parcelas nas faturas corretas e um Expense por
      // parcela — mesmo caminho usado pela tela de Cartões.
      return this.creditCardsService.createPurchase(
        {
          creditCardId: data.creditCardId,
          familyId: person.familyId,
          ownerId: data.personId,
          categoryId: data.categoryId,
          categoryName: data.categoryName,
          description: data.description,
          purchaseDate: data.date,
          totalAmount: data.value,
          installments: data.installments ?? 1,
          isShared: data.isShared ?? true,
        },
        data.userId,
      )
    }

    const dateObj = new Date(data.date)
    const dateParts = data.date.split('T')[0].split('-')
    const month = dateParts.length === 3 ? parseInt(dateParts[1]) : dateObj.getUTCMonth() + 1
    const year = dateParts.length === 3 ? parseInt(dateParts[0]) : dateObj.getUTCFullYear()

    if (data.isRecurring) {
      let endDate: Date | undefined
      if (data.durationMonths && data.durationMonths > 0) {
        endDate = new Date(dateObj)
        endDate.setMonth(endDate.getMonth() + data.durationMonths)
      }

      const recurring = await this.recurringRepository.createRecurringExpense({
        description: data.description,
        value: data.value,
        categoryName: data.categoryName,
        personId: data.personId,
        startDate: dateObj,
        endDate,
      })

      return this.repository.createExpense({
        description: data.description,
        value: data.value,
        categoryName: data.categoryName,
        categoryId: data.categoryId,
        type: 'fixed',
        date: dateObj,
        month,
        year,
        personId: data.personId,
        status: data.status,
        recurringId: recurring.id,
        isShared: data.isShared ?? true,
      })
    }

    return this.repository.createExpense({
      description: data.description,
      value: data.value,
      categoryName: data.categoryName,
      categoryId: data.categoryId,
      type: 'variable',
      date: dateObj,
      month,
      year,
      personId: data.personId,
      status: data.status,
      isShared: data.isShared ?? true,
    })
  }

  async listExpenses(
    month: number,
    year: number,
    userId: string,
    familyId?: string,
    status?: string,
    page: number = 1,
    limit: number = 10,
    filters?: {
      search?: string
      categoryId?: string
      personId?: string
      tipo?: string
      valorMin?: number
      valorMax?: number
      dataInicio?: string
      dataFim?: string
      ordenacao?: string
    },
  ) {
    if (familyId) {
      const family = await this.familiesService.getFamily(familyId, userId)
      if (!family) throw new Error('Acesso negado à família')

      await Promise.all([
        this.recurringExpensesService.processRecurringExpenses(familyId, month, year),
        this.incomesService.processRecurringIncomes(familyId, month, year),
      ])
      return this.repository.getExpensesByFamily(familyId, month, year, status, page, limit, filters)
    }

    return this.repository.getExpensesByUserId(userId, month, year, status, page, limit)
  }

  async getExpenseById(id: string, userId: string) {
    const expense = await this.repository.getExpenseById(id, userId)

    if (!expense) throw new Error('Despesa não encontrada')

    return expense
  }

  async getExpensesByFamily(familyId: string, month: number, year: number) {
    return this.repository.getAllExpensesByFamily(familyId, month, year)
  }

  async updateExpense(id: string, data: UpdateExpenseInput, userId: string) {
    // Validar se o registro pertence à família do usuário (não apenas o personId enviado)
    const existing = await this.repository.getExpenseById(id, userId)
    if (!existing) {
      throw new Error('Despesa não encontrada ou você não tem permissão para editá-la')
    }

    // Lançamentos pagos no cartão (parcela ou fatura agregada) têm valor,
    // data e responsável definidos pela compra/fatura: só descrição e
    // categoria podem ser editadas. Mudar o resto exige excluir e lançar de
    // novo (parcela) ou não se aplica (fatura).
    if (existing.purchaseId || existing.creditCardInvoiceId) {
      return this.repository.updateExpense(id, {
        description: data.description,
        categoryName: data.categoryName,
        categoryId: data.categoryId,
      })
    }

    // Validar se a pessoa pertence à família do usuário
    if (data.personId) {
      const isValid = await this.personsService.validatePersonBelongsToUserFamily(
        data.personId,
        userId,
      )

      if (!isValid) {
        throw new Error('Pessoa inválida ou não pertence à sua família')
      }
    }

    const dateObj = new Date(data.date)
    const dateParts = data.date.split('T')[0].split('-')
    const month = dateParts.length === 3 ? parseInt(dateParts[1]) : dateObj.getUTCMonth() + 1
    const year = dateParts.length === 3 ? parseInt(dateParts[0]) : dateObj.getUTCFullYear()

    return this.repository.updateExpense(id, {
      description: data.description,
      value: data.value,
      categoryName: data.categoryName,
      categoryId: data.categoryId,
      date: dateObj,
      month,
      year,
      personId: data.personId,
      status: data.status,
      isShared: data.isShared,
    })
  }

  async updateStatus(id: string, status: string) {
    const expense = await this.repository.getExpenseByIdRaw(id)
    if (!expense) throw new Error('Despesa não encontrada')

    // Parcela de compra no cartão: já nasce paga, não muda de status por aqui.
    if (expense.purchaseId) {
      throw new Error(
        'Esta parcela já está paga — foi quitada com o cartão no momento da compra.',
      )
    }

    // Lançamento agregado da fatura: só aceita virar PAID, e isso precisa
    // passar pelo mesmo caminho da tela de Cartões (recompõe limite e fatura).
    if (expense.creditCardInvoiceId) {
      if (status !== 'PAID') {
        throw new Error('A fatura só pode ser marcada como paga, não como pendente ou atrasada.')
      }
      await this.creditCardsService.payInvoice(expense.creditCardInvoiceId, expense.value)
      return this.repository.getExpenseByIdRaw(id)
    }

    return this.repository.updateStatus(id, status)
  }

  async addPayment(expenseId: string, data: {
    amount: number
    paidAt?: string
    note?: string
    transferToNextMonth?: boolean
  }, userId: string) {
    const expense = await this.repository.getExpenseByIdRaw(expenseId)
    if (!expense) throw new Error('Despesa não encontrada')

    const remaining = expense.value - expense.paidAmount
    if (data.amount <= 0) throw new Error('O valor do pagamento deve ser maior que zero')
    if (data.amount > remaining + 0.001) {
      throw new Error(`Valor informado (${data.amount}) excede o saldo pendente (${remaining.toFixed(2)})`)
    }

    const newPaidAmount = parseFloat((expense.paidAmount + data.amount).toFixed(2))
    const remainingAfter = parseFloat((expense.value - newPaidAmount).toFixed(2))
    const isFullyPaid = remainingAfter <= 0.001

    // Determine next month/year for transfer
    const nextMonth = expense.month === 12 ? 1 : expense.month + 1
    const nextYear = expense.month === 12 ? expense.year + 1 : expense.year
    const nextDate = new Date(nextYear, nextMonth - 1, 1)
    const nextDateISO = `${nextYear}-${String(nextMonth).padStart(2, '0')}-01`

    const noteText = data.transferToNextMonth && !isFullyPaid
      ? `${data.note ? data.note + ' · ' : ''}Pagamento parcial: ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(data.amount)} · Saldo ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(remainingAfter)} transferido para ${String(nextMonth).padStart(2, '0')}/${nextYear}`
      : data.note

    // Register payment record
    await this.repository.addPayment(expenseId, {
      amount: data.amount,
      paidAt: data.paidAt ? new Date(data.paidAt) : new Date(),
      note: noteText,
      remainingAfter: Math.max(0, remainingAfter),
    })

    if (data.transferToNextMonth && !isFullyPaid) {
      // Close current expense: mark as PAID with the amount effectively paid
      await this.repository.updatePaidAmount(expenseId, expense.value, 'PAID')
      await this.repository.updateExpense(expenseId, {
        description: expense.description,
        value: newPaidAmount,
        categoryName: expense.categoryName,
        categoryId: expense.categoryId ?? undefined,
        date: expense.date,
        month: expense.month,
        year: expense.year,
        personId: expense.personId,
        status: 'PAID',
        recurringId: expense.recurringId ?? undefined,
        isShared: expense.isShared,
      })

      // Create new expense for next month with remaining balance
      await this.repository.createExpense({
        description: expense.description,
        value: remainingAfter,
        categoryName: expense.categoryName,
        categoryId: expense.categoryId ?? undefined,
        type: expense.type,
        date: nextDate,
        month: nextMonth,
        year: nextYear,
        personId: expense.personId,
        status: 'PENDING',
        recurringId: expense.recurringId ?? undefined,
        isShared: expense.isShared,
        originExpenseId: expenseId,
        originMonth: expense.month,
        originYear: expense.year,
      })
    } else {
      const newStatus = isFullyPaid ? 'PAID' : 'PARTIALLY_PAID'
      await this.repository.updatePaidAmount(expenseId, newPaidAmount, newStatus)
    }

    return this.repository.getExpenseByIdRaw(expenseId)
  }

  async getPayments(expenseId: string) {
    return this.repository.getPayments(expenseId)
  }

  async deletePayment(paymentId: string, expenseId: string) {
    const expense = await this.repository.getExpenseByIdRaw(expenseId)
    if (!expense) throw new Error('Despesa não encontrada')

    const payment = expense.payments.find((p: any) => p.id === paymentId)
    if (!payment) throw new Error('Pagamento não encontrado')

    await this.repository.deletePayment(paymentId)

    // Recalculate paidAmount from remaining payments
    const remainingPayments = expense.payments.filter((p: any) => p.id !== paymentId)
    const newPaidAmount = parseFloat(
      remainingPayments.reduce((sum: number, p: any) => sum + p.amount, 0).toFixed(2)
    )
    const remainingBalance = parseFloat((expense.value - newPaidAmount).toFixed(2))
    const newStatus = newPaidAmount <= 0 ? 'PENDING'
      : remainingBalance <= 0.001 ? 'PAID'
      : 'PARTIALLY_PAID'

    await this.repository.updatePaidAmount(expenseId, newPaidAmount, newStatus)

    return this.repository.getExpenseByIdRaw(expenseId)
  }

  async deleteExpense(id: string, userId: string) {
    const existing = await this.repository.getExpenseById(id, userId)
    if (!existing) {
      throw new Error('Despesa não encontrada ou você não tem permissão para excluí-la')
    }

    // Lançamento vindo de uma compra no cartão: exclui a compra inteira
    // (todas as parcelas), não apenas esta linha.
    if (existing.purchaseId) {
      return this.creditCardsService.deletePurchase(existing.purchaseId, userId)
    }

    // Lançamento agregado da fatura: não faz sentido excluir uma fatura —
    // ou ela é paga, ou fica pendente até você pagar.
    if (existing.creditCardInvoiceId) {
      throw new Error(
        'Não é possível excluir a fatura. Marque como paga quando quitar o cartão.',
      )
    }

    return this.repository.deleteExpense(id)
  }
}
