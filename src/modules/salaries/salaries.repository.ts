import { prisma } from '@/lib/prisma'
import _ from 'lodash'

export class SalariesRepository {
  private prisma = prisma.salary
  async getSalary(personId: string, month: number, year: number) {
    return this.prisma.findUnique({
      where: {
        personId_month_year: {
          personId,
          month,
          year,
        },
      },
    })
  }

  async getSalariesByFamily(familyId: string, month: number, year: number) {
    return this.prisma.findMany({
      where: {
        person: { familyId },
        month,
        year,
        is_deleted: false,
      },
    })
  }

  async upsertSalary(data: { personId: string; value: number; month: number; year: number }) {
    const { personId, value, month, year } = data
    return this.prisma.upsert({
      where: {
        personId_month_year: {
          personId,
          month,
          year,
        },
      },
      update: {
        value,
      },
      create: {
        personId,
        value,
        month,
        year,
      },
    })
  }

  async updateSalary(
    id: string,
    data: Partial<{ value: number; month: number; year: number; personId: string }>,
  ) {
    const updateData = _.pickBy(data, (v) => v !== undefined)
    return this.prisma.update({
      where: { id },
      data: updateData,
    })
  }

  async deleteSalary(id: string) {
    return this.prisma.update({
      where: { id },
      data: { is_deleted: true, dt_deleted: new Date() },
    })
  }
}
