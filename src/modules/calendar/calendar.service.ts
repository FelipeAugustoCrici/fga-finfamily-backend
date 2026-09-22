import { prisma } from '@/lib/prisma'
import { FamiliesService } from '@/modules/families/families.service'
import { RecurringExpensesService } from '@/modules/recurring-expenses/recurring-expenses.service'
import { IncomesService } from '@/modules/incomes/incomes.service'

export class CalendarService {
  private familiesService = new FamiliesService()
  private recurringExpensesService = new RecurringExpensesService()
  private incomesService = new IncomesService()

  async getCalendarEvents(month: number, year: number, familyId: string, userId: string) {
    const family = await this.familiesService.getFamily(familyId, userId)
    if (!family) throw new Error('Acesso negado à família')

    // Processa recorrências antes de buscar
    await Promise.all([
      this.recurringExpensesService.processRecurringExpenses(familyId, month, year),
      this.incomesService.processRecurringIncomes(familyId, month, year),
    ])

    const [expenses, incomes, extras] = await Promise.all([
      prisma.expense.findMany({
        // purchaseId: null — parcela de compra no cartão já nasce paga, mas o
        // dinheiro só sai de verdade quando a fatura é paga. Sem esse filtro,
        // o saldo do dia conta a mesma compra duas vezes (dia da compra e
        // dia do vencimento da fatura).
        where: { person: { familyId }, month, year, is_deleted: false, purchaseId: null },
        include: { category: true, recurring: true },
        orderBy: { date: 'asc' },
      }),
      prisma.income.findMany({
        where: { person: { familyId }, month, year, is_deleted: false },
        include: { source: true },
        orderBy: { date: 'asc' },
      }),
      prisma.extraIncome.findMany({
        where: { person: { familyId }, month, year, is_deleted: false },
        orderBy: { date: 'asc' },
      }),
    ])

    const toEvent = (r: any, type: 'income' | 'expense', sourceType: string) => ({
      id: r.id,
      description: r.description,
      value: r.value,
      date: r.date,
      month: r.month,
      year: r.year,
      type,
      sourceType,
      status: r.status ?? null,
      category: r.category ?? null,
      categoryName: r.categoryName ?? r.category?.name ?? null,
      personId: r.personId,
      isRecurring: !!(r.recurringId ?? r.sourceId),
    })

    return {
      expenses: expenses.map((r) => toEvent(r, 'expense', 'expenses')),
      incomes: incomes.map((r) => toEvent(r, 'income', 'incomes')),
      extras: extras.map((r) => toEvent(r, 'income', 'extras')),
    }
  }
}
