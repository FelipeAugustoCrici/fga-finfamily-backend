import { CreateIncomeInput } from './dtos'
import { IncomesRepository } from './incomes.repository'
import { IncomesSourcesRepository } from '@/modules/incomes-sources/incomes-sources.repository'
import { FamiliesService } from '@/modules/families/families.service'
import { PersonsService } from '@/modules/persons/persons.service'

export class IncomesService {
  private repository: IncomesRepository = new IncomesRepository()
  private familiesService: FamiliesService = new FamiliesService()
  private personsService: PersonsService = new PersonsService()
  private repositoryIncomeSource: IncomesSourcesRepository = new IncomesSourcesRepository()

  async createIncome(data: CreateIncomeInput & { userId: string }) {
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

    if (data.isRecurring && data.type === 'fixed') {
      let endDate: Date | undefined
      if (data.durationMonths && data.durationMonths > 0) {
        endDate = new Date(dateObj)
        endDate.setMonth(endDate.getMonth() + data.durationMonths)
      }

      const source = await this.repositoryIncomeSource.createIncomeSource({
        description: data.description,
        value: data.value,
        type: data.type,
        isRecurring: true,
        startDate: dateObj,
        endDate,
        personId: data.personId,
      })

      return this.repository.createIncome({
        description: data.description,
        value: data.value,
        date: dateObj,
        month,
        year,
        type: data.type,
        personId: data.personId,
        sourceId: source.id,
      })
    }

    return this.repository.createIncome({
      description: data.description,
      value: data.value,
      date: dateObj,
      month,
      year,
      type: data.type,
      personId: data.personId,
    })
  }

  async listIncomes(month: number, year: number, userId: string, familyId?: string) {
    if (familyId) {
      const family = await this.familiesService.getFamily(familyId, userId)

      if (!family) {
        throw new Error('Acesso negado à família')
      }

      return this.repository.getIncomesByFamily(familyId, month, year)
    }
    return this.repository.getIncomesByUserId(userId, month, year)
  }

  async getIncomeById(id: string, userId: string) {
    const family = await this.familiesService.getFamilyByUserId(userId)
    return this.repository.getIncomeById(id, family?.id)
  }

  async processRecurringIncomes(familyId: string, month: number, year: number) {
    const sources = await this.repositoryIncomeSource.getIncomeSourcesByFamily(familyId)
    const targetDate = new Date(year, month - 1, 1)

    for (const source of sources) {
      const startDate = new Date(source.startDate)
      const startMonth = startDate.getMonth() + 1
      const startYear = startDate.getFullYear()

      if (year < startYear || (year === startYear && month < startMonth)) {
        continue
      }

      if (source.endDate) {
        const endDate = new Date(source.endDate)
        if (endDate < targetDate) {
          continue
        }
      }

      const alreadyExists = source.incomes.some((i) => i.month === month && i.year === year)

      if (!alreadyExists) {
        await this.repository.createIncome({
          description: source.description,
          value: source.value,
          date: targetDate,
          month,
          year,
          type: source.type,
          personId: source.personId,
          sourceId: source.id,
        })
      }
    }
  }

  async getIncomesByFamily(familyId: string, month: number, year: number) {
    return this.repository.getIncomesByFamily(familyId, month, year)
  }

  async updateIncome(
    id: string,
    data: Partial<{
      description: string
      value: number
      date: Date
      personId: string
      month: number
      year: number
      type: string
    }>,
    userId: string,
  ) {
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

    return this.repository.updateIncome(id, data)
  }

  async deleteIncome(id: string) {
    return this.repository.deleteIncome(id)
  }
}
