import { PersonsRepository } from './persons.repository'
import { UpdatePersonInput } from '@/modules/persons/dtos/update-person.schema'
import { CreatePersonInput, CreatePersonData } from './dtos/create-person.schema'
import { cognitoService } from '@/shared/cognito/cognito.service'

export class PersonsService {
  private repository: PersonsRepository = new PersonsRepository()

  async createPerson(data: CreatePersonData) {
    const { hasAccess, temporaryPassword, ...personData } = data as any

    if (hasAccess) {
      if (!personData.email) {
        throw new Error('E-mail é obrigatório para conceder acesso à plataforma')
      }

      const exists = await cognitoService.userExists(personData.email)
      if (exists) {
        throw new Error('Já existe um usuário com este e-mail no sistema')
      }

      const cognitoSub = await cognitoService.createUser({
        email: personData.email,
        name: personData.name,
        temporaryPassword: temporaryPassword || undefined,
      })

      return this.repository.createPerson({ ...personData, userId: cognitoSub, hasAccess: true })
    }

    return this.repository.createPerson(personData)
  }

  async getPerson(id: string, userId: string) {
    return this.repository.getPerson(id, userId)
  }

  async getPersonByUserId(userId: string) {
    return this.repository.getPersonByUserId(userId)
  }

  async updatePerson(userId: string, data: UpdatePersonInput) {
    return this.repository.updatePerson(userId, data)
  }

  async deletePerson(id: string) {
    return this.repository.deletePerson(id)
  }

  async validatePersonBelongsToUserFamily(personId: string, userId: string): Promise<boolean> {
    const person = await this.repository.getPersonWithFamily(personId)
    if (!person || !person.familyId) return false

    const userPerson = await this.repository.getPersonByUserId(userId)
    if (!userPerson || !userPerson.familyId) return false

    console.log(`[VALIDATE] personId: ${personId} familyId: ${person.familyId} | userPerson: ${userPerson.id} familyId: ${userPerson.familyId} | userId: ${userId}`)

    return person.familyId === userPerson.familyId
  }

  async getPersonWithFamily(personId: string) {
    return this.repository.getPersonWithFamily(personId)
  }
}
