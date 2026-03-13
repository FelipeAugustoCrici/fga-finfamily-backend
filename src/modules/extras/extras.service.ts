import { ExtrasRepository } from '@/modules/extras/extras.repository'
import { CreateExtraInput } from '@/modules/extras/dtos/create-extra.schema'
import { PersonsService } from '@/modules/persons/persons.service'

export class ExtrasService {
  private repository: ExtrasRepository = new ExtrasRepository()
  private personsService: PersonsService = new PersonsService()

  async createExtraIncome(data: CreateExtraInput & { userId: string }) {
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

    return this.repository.createExtraIncome({
      description: data.description,
      value: data.value,
      personId: data.personId,
      date: dateObj,
      month,
      year,
    })
  }

  async updateExtraIncome(
    id: string,
    data: Partial<{
      description: string
      value: number
      date: Date
      month: number
      year: number
      personId: string
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

    return this.repository.updateExtraIncome(id, data)
  }

  async listExtras(month: number, year: number) {
    return this.repository.getExtras(month, year)
  }

  async getExtrasByFamily(familyId: string, month: number, year: number) {
    return this.repository.getExtrasByFamily(familyId, month, year)
  }

  async deleteExtraIncome(id: string) {
    return this.repository.deleteExtraIncome(id)
  }
}
