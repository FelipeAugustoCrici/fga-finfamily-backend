/**
 * Gera os Expense retroativos para compras de cartão já cadastradas antes
 * do vínculo entre CreditCardPurchase/CreditCardInstallment e Expense
 * existir. Sem isso, essas compras não entram no saldo, no calendário nem
 * nos resumos — só aparecem na tela de Cartões.
 *
 * Idempotente: só cria Expense para parcelas que ainda não têm uma
 * (installment.expense === null). Rodar de novo não duplica nada.
 *
 * Uso:
 *   DATABASE_URL="postgresql://postgres:postgres@localhost:5433/finfamily?schema=public" \
 *     npx tsx scripts/backfill-credit-card-expenses.ts
 */
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

/**
 * Soma `months` meses a uma data, ajustando para o último dia do mês de
 * destino quando o dia original não existir nele. Mesma lógica usada em
 * CreditCardsService.createPurchase — mantém as duas fontes consistentes.
 */
function addMonthsClamped(date: Date, months: number): Date {
  const targetIndex = date.getMonth() + months
  const year = date.getFullYear() + Math.floor(targetIndex / 12)
  const month = ((targetIndex % 12) + 12) % 12
  const lastDayOfTargetMonth = new Date(year, month + 1, 0).getDate()
  const day = Math.min(date.getDate(), lastDayOfTargetMonth)
  return new Date(year, month, day)
}

async function main() {
  const installments = await prisma.creditCardInstallment.findMany({
    where: { expense: null },
    include: {
      invoice: true,
      purchase: { include: { category: true } },
    },
    orderBy: { referenceYear: 'asc' },
  })

  let created = 0
  let skippedNoOwner = 0

  for (const installment of installments) {
    const purchase = installment.purchase

    if (!purchase.ownerId) {
      skippedNoOwner++
      console.log(
        `pulado (sem responsável): compra "${purchase.description}" (${purchase.id}), parcela ${installment.installmentNumber}/${installment.totalInstallments}`,
      )
      continue
    }

    const categoryName = purchase.category?.name || 'Geral'
    const isPaid = installment.invoice.status === 'paid'
    const description =
      purchase.totalInstallments && purchase.totalInstallments > 1
        ? purchase.description
        : purchase.description

    // Parcela 1 no mês da compra, parcela 2 no mês seguinte, etc. — mesma
    // regra da criação normal, independente do mês em que a fatura vence.
    const listingDate = addMonthsClamped(
      purchase.purchaseDate,
      installment.installmentNumber - 1,
    )

    await prisma.expense.create({
      data: {
        description:
          installment.totalInstallments > 1
            ? `${purchase.description} (${installment.installmentNumber}/${installment.totalInstallments})`
            : description,
        value: installment.amount,
        categoryName,
        categoryId: purchase.categoryId,
        type: 'variable',
        date: listingDate,
        month: listingDate.getMonth() + 1,
        year: listingDate.getFullYear(),
        paymentMethod: 'credit_card',
        isCreditCard: true,
        creditCardId: purchase.creditCardId,
        purchaseId: purchase.id,
        installmentId: installment.id,
        personId: purchase.ownerId,
        status: isPaid ? 'PAID' : 'PENDING',
        paidAmount: isPaid ? installment.amount : 0,
        isShared: true,
      },
    })
    created++
  }

  console.log('---')
  console.log(`Parcelas encontradas sem Expense: ${installments.length}`)
  console.log(`Expenses criados: ${created}`)
  console.log(`Pulados por falta de responsável (ownerId): ${skippedNoOwner}`)
  if (skippedNoOwner > 0) {
    console.log(
      'Essas compras precisam de um responsável definido antes de entrar no saldo. Edite a compra na tela de Cartões, ou rode o script de novo depois de associá-las.',
    )
  }
}

main()
  .catch((err) => {
    console.error(err)
    process.exitCode = 1
  })
  .finally(() => prisma.$disconnect())
