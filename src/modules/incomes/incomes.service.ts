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
    // targetDate usado apenas para comparação de endDate
    const targetDate = new Date(Date.UTC(year, month - 1, 1))

    for (const source of sources) {
      const startDate = new Date(source.startDate)
      const startMonth = startDate.getUTCMonth() + 1
      const startYear = startDate.getUTCFullYear()
      // Preserva o dia original do cadastro
      const originalDay = startDate.getUTCDate()

      if (year < startYear || (year === startYear && month < startMonth)) {
        continue
      }

      if (source.endDate) {
        const endDate = new Date(source.endDate)
        if (endDate < targetDate) {
          continue
        }
      }

      const alreadyExists = source.incomes.some(
        (i: { month: number; year: number }) => i.month === month && i.year === year,
      )

      if (!alreadyExists) {
        // Garante que o dia não ultrapasse o último dia do mês
        const daysInMonth = new Date(Date.UTC(year, month, 0)).getUTCDate()
        const day = Math.min(originalDay, daysInMonth)
        const recurringDate = new Date(Date.UTC(year, month - 1, day))

        await this.repository.createIncome({
          description: source.description,
          value: source.value,
          date: recurringDate,
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
      date: string
      personId: string
      type: string
    }>,
    userId: string,
  ) {
    // Validar se o registro pertence à família do usuário (não apenas o personId enviado)
    const existing = await this.getIncomeById(id, userId)
    if (!existing) {
      throw new Error('Renda não encontrada ou você não tem permissão para editá-la')
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

    const updateData: Partial<{
      description: string
      value: number
      date: Date
      personId: string
      month: number
      year: number
      type: string
    }> = { ...data, date: undefined }

    if (data.date) {
      const dateObj = new Date(data.date)
      const dateParts = data.date.split('T')[0].split('-')
      updateData.date = dateObj
      updateData.month = dateParts.length === 3 ? parseInt(dateParts[1]) : dateObj.getUTCMonth() + 1
      updateData.year = dateParts.length === 3 ? parseInt(dateParts[0]) : dateObj.getUTCFullYear()
    }

    return this.repository.updateIncome(id, updateData)
  }

  async deleteIncome(id: string, userId: string) {
    const existing = await this.getIncomeById(id, userId)
    if (!existing) {
      throw new Error('Renda não encontrada ou você não tem permissão para excluí-la')
    }

    return this.repository.deleteIncome(id)
  }
}
