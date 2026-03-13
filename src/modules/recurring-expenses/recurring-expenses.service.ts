import { RecurringExpensesRepository } from '@/modules/recurring-expenses/recurring-expenses.repository'
import { ExpensesRepository } from '@/modules/expenses/expenses.repository'

export class RecurringExpensesService {
  private repository: RecurringExpensesRepository = new RecurringExpensesRepository()
  private expensesRepository: ExpensesRepository = new ExpensesRepository()

  async processRecurringExpenses(familyId: string, month: number, year: number) {
    const recurringFamily = await this.repository.getRecurringExpensesByFamily(familyId)
    const targetDate = new Date(year, month - 1, 1)

    for (const recurring of recurringFamily) {
      const startDate = new Date(recurring.startDate)
      const startMonth = startDate.getMonth() + 1
      const startYear = startDate.getFullYear()

      if (year < startYear || (year === startYear && month < startMonth)) continue

      if (recurring.endDate) {
        const endDate = new Date(recurring.endDate)
        if (endDate < targetDate) continue
      }

      const alreadyExists = recurring.expenses.some((e) => e.month === month && e.year === year)

      if (!alreadyExists) {
        await this.expensesRepository.createExpense({
          description: recurring.description,
          value: recurring.value,
          categoryName: recurring.categoryName,
          type: 'fixed',
          date: targetDate,
          month,
          year,
          personId: recurring.personId,
          recurringId: recurring.id,
        })
      }
    }
  }
}
