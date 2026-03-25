import { prisma } from '@/lib/prisma'
import { UpdatePersonInput } from '@/modules/persons/dtos/update-person.schema'
import { CreatePersonInput } from './dtos/create-person.schema'

export class PersonsRepository {
  async createPerson(data: CreatePersonInput) {
    const prismaData: any = { ...data }

    if (data.birthDate) {
      prismaData.birthDate = new Date(data.birthDate)
    }

    return prisma.person.create({ data: prismaData })
  }

  async getPerson(id: string, userId: string) {
    return prisma.person.findUnique({
      where: { id, userId },
      include: { family: true },
    })
  }

  async getPersonByUserId(userId: string) {
    return prisma.person.findFirst({
      where: { userId, hasAccess: true },
      include: { family: true },
    })
  }

  async updatePerson(userId: string, data: UpdatePersonInput) {
    const person = await this.getPersonByUserId(userId)

    if (!person) throw new Error('Person not found')

    const updateData: any = { ...data }

    if (data.birthDate) {
      updateData.birthDate = new Date(data.birthDate)
    }

    return (prisma.person as any).update({
      where: { id: person.id },
      data: updateData,
    })
  }

  async deletePerson(id: string) {
    return prisma.person.delete({
      where: { id },
    })
  }

  async getPersonWithFamily(personId: string) {
    return prisma.person.findUnique({
      where: { id: personId },
      include: { family: true },
    })
  }
}
