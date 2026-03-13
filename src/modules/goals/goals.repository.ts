import { prisma } from '@/lib/prisma'

export class GoalsRepository {
  private prisma = prisma.goal

  async createGoal(data: {
    description: string
    targetValue: number
    currentValue?: number
    deadline?: Date
  }) {
    return this.prisma.create({ data })
  }

  async getGoals() {
    return this.prisma.findMany()
  }

  async updateGoal(id: string, data: { currentValue?: number }) {
    return this.prisma.update({
      where: { id },
      data,
    })
  }

  async getGoalById(id: string) {
    return this.prisma.findUnique({
      where: { id },
    })
  }

  async deleteGoal(id: string) {
    return this.prisma.delete({
      where: { id },
    })
  }
}
