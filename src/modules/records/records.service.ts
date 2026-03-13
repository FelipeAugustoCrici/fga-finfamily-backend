import { SalariesService } from '@/modules/salaries/salaries.service'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { ExpensesService } from '@/modules/expenses/expenses.service'
import { ExtrasService } from '@/modules/extras/extras.service'

export class RecordsService {
  private salariesService: SalariesService = new SalariesService()
  private extrasService: ExtrasService = new ExtrasService()
  private incomeService: IncomesService = new IncomesService()
  private expenseService: ExpensesService = new ExpensesService()

  async deleteRecord(
    type: 'salaries' | 'extras' | 'incomes' | 'expenses',
    id: string,
    userId: string,
  ) {
    // Aqui poderíamos validar se o id pertence ao userId antes de deletar
    switch (type) {
      case 'salaries':
        return this.salariesService.deleteSalary(id)
      case 'extras':
        return this.extrasService.deleteExtraIncome(id)
      case 'incomes':
        return this.incomeService.deleteIncome(id)
      case 'expenses':
        return this.expenseService.deleteExpense(id)
      default:
        throw new Error('Tipo de registro inválido')
    }
  }

  async updateRecord(
    type: 'salaries' | 'extras' | 'incomes' | 'expenses',
    id: string,
    data: any,
    userId: string,
  ) {
    const dateObj = data.date ? new Date(data.date) : undefined
    let month = data.month
    let year = data.year

    if (data.date && !month && !year) {
      const dateParts = String(data.date).split('T')[0].split('-')
      month = dateParts.length === 3 ? parseInt(dateParts[1]) : dateObj!.getUTCMonth() + 1
      year = dateParts.length === 3 ? parseInt(dateParts[0]) : dateObj!.getUTCFullYear()
    }

    switch (type) {
      case 'salaries':
        return this.salariesService.updateSalary(id, {
          value: data.value,
          personId: data.personId,
          month,
          year,
        })
      case 'extras':
        return this.extrasService.updateExtraIncome(id, {
          description: data.description,
          value: data.value,
          date: dateObj,
          personId: data.personId,
          month,
          year,
        })
      case 'incomes':
        return this.incomeService.updateIncome(id, {
          description: data.description,
          value: data.value,
          date: dateObj,
          personId: data.personId,
          month,
          year,
          type: data.type,
        })
      case 'expenses':
        return this.expenseService.updateExpense(id, {
          description: data.description,
          value: data.value,
          categoryName: data.categoryName,
          categoryId: data.categoryId,
          date: dateObj,
          personId: data.personId,
          month,
          year,
        })
      default:
        throw new Error('Tipo de registro inválido')
    }
  }
}
