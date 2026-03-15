import { PersonsRepository } from './persons.repository'
import { UpdatePersonInput } from '@/modules/persons/dtos/update-person.schema'
import { CreatePersonInput, CreatePersonData } from './dtos/create-person.schema'

export class PersonsService {
  private repository: PersonsRepository = new PersonsRepository()

  async createPerson(data: CreatePersonData) {
    return this.repository.createPerson(data)
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
    // Buscar a pessoa com sua família
    const person = await this.repository.getPersonWithFamily(personId)
    
    if (!person || !person.familyId) {
      return false
    }

    // Buscar a pessoa do usuário logado para pegar sua família
    const userPerson = await this.repository.getPersonByUserId(userId)
    
    if (!userPerson || !userPerson.familyId) {
      return false
    }

    // Verificar se ambos pertencem à mesma família
    return person.familyId === userPerson.familyId
  }

  async getPersonWithFamily(personId: string) {
    return this.repository.getPersonWithFamily(personId)
  }
}
