import { prisma } from '@/lib/prisma'

export class IncomesSourcesRepository {
  private prisma = prisma.incomeSource

  async createIncomeSource(data: {
    description: string
    value: number
    type: string
    isRecurring?: boolean
    startDate: Date
    endDate?: Date
    personId: string
  }) {
    return this.prisma.create({ data })
  }
  async getIncomeSourcesByFamily(familyId: string) {
    return this.prisma.findMany({
      where: {
        person: { familyId },
        active: true,
      },
      include: {
        incomes: true,
      },
    })
  }

  async updateIncomeSource(id: string, data: Partial<{ active: boolean; value: number }>) {
    return this.prisma.update({
      where: { id },
      data,
    })
  }
}
