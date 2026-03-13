import { prisma } from '@/lib/prisma'
import _ from 'lodash'

export class IncomesRepository {
  private prisma = prisma.income

  async createIncome(data: {
    description: string
    value: number
    date: Date
    month: number
    year: number
    type: string
    personId: string
    sourceId?: string
  }) {
    return this.prisma.create({ data })
  }

  async getIncomesByFamily(familyId: string, month: number, year: number) {
    return this.prisma.findMany({
      where: {
        person: { familyId },
        month,
        year,
        is_deleted: false,
      },
      include: {
        source: true,
      },
      orderBy: { date: 'asc' },
    })
  }

  async getIncomeById(id: string, familyId?: string) {
    if (!familyId) return

    return this.prisma.findUnique({
      where: { id, person: { familyId } },
      include: {
        person: {
          include: { family: true },
        },
      },
    })
  }

  async updateIncome(
    id: string,
    data: Partial<{
      description: string
      value: number
      date: Date
      month: number
      year: number
      type: string
      personId: string
    }>,
  ) {
    const updateData = _.pickBy(data, (v) => v !== undefined)
    return this.prisma.update({
      where: { id },
      data: updateData,
    })
  }

  async deleteIncome(id: string) {
    return this.prisma.update({
      where: { id },
      data: { is_deleted: true, dt_deleted: new Date() },
    })
  }
  async getIncomesByUserId(userId: string, month: number, year: number) {
    return this.prisma.findMany({
      where: {
        person: { userId },
        month,
        year,
        is_deleted: false,
      },
      include: {
        source: true,
      },
      orderBy: { date: 'asc' },
    })
  }
}
