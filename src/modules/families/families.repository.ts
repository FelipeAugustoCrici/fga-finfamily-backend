import { prisma } from '@/lib/prisma'

export class FamiliesRepository {
  async createFamily(data: { name: string }) {
    return prisma.family.create({ data })
  }

  async listFamilies(userId: string) {
    return prisma.family.findMany({
      where: {
        members: {
          some: { userId },
        },
      },
      include: { members: true },
    })
  }

  async getFamily(id: string, userId: string) {
    return prisma.family.findFirst({
      where: { 
        id,
        members: { some: { userId } } 
      },
      include: {
        members: {
          include: {
            salaries: true,
            extraIncomes: true,
            expenses: true,
          },
        },
      },
    })
  }

  async getFamilyByUserId(userId: string) {
    return prisma.family.findFirst({
      where: { members: { some: { userId } } },
      include: {
        members: {
          include: {
            salaries: true,
            extraIncomes: true,
            expenses: true,
          },
        },
      },
    })
  }

  async updateFamily(id: string, data: { name: string }, userId: string) {
    // Verificar se o usuário tem acesso à família
    const family = await this.getFamily(id, userId)
    if (!family) {
      throw new Error('Família não encontrada ou acesso negado')
    }

    return prisma.family.update({
      where: { id },
      data,
      include: { members: true },
    })
  }

  async deleteFamily(id: string, userId: string) {
    // Verificar se o usuário tem acesso à família
    const family = await this.getFamily(id, userId)
    if (!family) {
      throw new Error('Família não encontrada ou acesso negado')
    }

    return prisma.family.delete({
      where: { id },
    })
  }
}
