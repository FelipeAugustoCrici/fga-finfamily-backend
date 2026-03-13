import { prisma } from '@/lib/prisma'

export class BudgetsRepository {
  private prisma = prisma.budget

  async upsertBudget(data: {
    categoryName: string
    categoryId?: string
    limitValue: number
    month: number
    year: number
  }) {
    return this.prisma.upsert({
      where: {
        categoryName_month_year: {
          categoryName: data.categoryName,
          month: data.month,
          year: data.year,
        },
      },
      update: {
        limitValue: data.limitValue,
        categoryId: data.categoryId,
      },
      create: data,
    })
  }

  async listBudgets(month: number, year: number) {
    return this.prisma.findMany({
      where: { month, year },
      include: { category: true },
    })
  }

  async getBudgetById(id: string) {
    return this.prisma.findUnique({
      where: { id },
      include: { category: true },
    })
  }

  async deleteBudget(id: string) {
    return this.prisma.delete({
      where: { id },
    })
  }
}