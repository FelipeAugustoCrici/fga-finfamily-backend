import { prisma } from '@/lib/prisma'
import { ExpensesRepository } from './expenses.repository'
import { RecurringExpensesRepository } from '@/modules/recurring-expenses/recurring-expenses.repository'
import { RecurringExpensesService } from '@/modules/recurring-expenses/recurring-expenses.service'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { UpdateExpenseInput } from '@/modules/expenses/dtos'
import { FamiliesService } from '@/modules/families/families.service'
import { PersonsService } from '@/modules/persons/persons.service'

export class ExpensesService {
  private incomesService: IncomesService = new IncomesService()
  private familiesService: FamiliesService = new FamiliesService()
  private personsService: PersonsService = new PersonsService()
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
    return this.repository.updateStatus(id, status)
  }

  async deleteExpense(id: string) {
    return this.repository.deleteExpense(id)
  }
}
