import { prisma } from '@/lib/prisma'

export class RecurringExpensesRepository {
  private prisma = prisma.recurringExpense

  async createRecurringExpense(data: {
    description: string
    value: number
    categoryName: string
    personId: string
    startDate: Date
    endDate?: Date
  }) {
    const { description, value, categoryName, personId, startDate, endDate } = data
    return this.prisma.create({
      data: { description, value, categoryName, personId, startDate, endDate },
    })
  }

  async getRecurringExpensesByFamily(familyId: string) {
    return this.prisma.findMany({
      where: {
        person: { familyId },
        active: true,
      },
      include: {
        expenses: true,
      },
    })
  }

  async updateRecurringExpense(id: string, data: Partial<{ active: boolean; value: number }>) {
    return this.prisma.update({
      where: { id },
      data,
    })
  }
}
