import { prisma } from '@/lib/prisma'
import _ from 'lodash'

export class ExtrasRepository {
  private repository = prisma.extraIncome

  async createExtraIncome(data: {
    description: string
    value: number
    date: Date
    month: number
    year: number
    personId: string
  }) {
    const { description, value, date, month, year, personId } = data
    return this.repository.create({
      data: { description, value, date, month, year, personId },
    })
  }

  async getExtras(month: number, year: number) {
    return this.repository.findMany({
      where: { month, year, is_deleted: false },
      orderBy: { date: 'asc' },
    })
  }

  async getExtrasByFamily(familyId: string, month: number, year: number) {
    return this.repository.findMany({
      where: {
        person: { familyId },
        month,
        year,
        is_deleted: false,
      },
      orderBy: { date: 'asc' },
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
  ) {
    const updateData = _.pickBy(data, (v) => v !== undefined)
    return this.repository.update({
      where: { id },
      data: updateData,
    })
  }

  async deleteExtraIncome(id: string) {
    return this.repository.update({
      where: { id },
      data: { is_deleted: true, dt_deleted: new Date() },
    })
  }
  async getExtrasByUserId(userId: string, month: number, year: number) {
    return this.repository.findMany({
      where: {
        person: { userId },
        month,
        year,
        is_deleted: false,
      },
      orderBy: { date: 'asc' },
    })
  }
}
