import { prisma } from '@/lib/prisma'

export class GoalsRepository {
  async createGoal(data: {
    description: string
    type?: string
    targetValue: number
    currentValue?: number
    deadline?: Date
    familyId?: string
    personId?: string
  }) {
    return prisma.goal.create({
      data,
      include: { contributions: { orderBy: { date: 'desc' } } },
    })
  }

  async getGoals(familyId?: string) {
    return prisma.goal.findMany({
      where: familyId ? { familyId } : undefined,
      include: { contributions: { orderBy: { date: 'desc' } } },
      orderBy: { createdAt: 'desc' },
    })
  }

  async getGoalById(id: string) {
    return prisma.goal.findUnique({
      where: { id },
      include: { contributions: { orderBy: { date: 'desc' } } },
    })
  }

  async updateGoal(id: string, data: { currentValue?: number; status?: string; description?: string; targetValue?: number; deadline?: Date }) {
    return prisma.goal.update({
      where: { id },
      data,
      include: { contributions: { orderBy: { date: 'desc' } } },
    })
  }

  async deleteGoal(id: string) {
    return prisma.goal.delete({ where: { id } })
  }

  async addContribution(goalId: string, data: { value: number; date?: Date; observation?: string; personId?: string; createExpense?: boolean }) {
    const goal = await prisma.goal.findUnique({ where: { id: goalId } })
    if (!goal) throw new Error('Goal not found')

    const contributionDate = data.date ?? new Date()
    const dateStr = contributionDate.toISOString().split('T')[0]
    const month = contributionDate.getMonth() + 1
    const year = contributionDate.getFullYear()

    const [contribution] = await prisma.$transaction(async (tx) => {
      const contrib = await tx.goalContribution.create({
        data: { goalId, value: data.value, date: contributionDate, observation: data.observation },
      })

      const newValue = goal.currentValue + data.value
      const status = newValue >= goal.targetValue ? 'completed' : 'active'
      await tx.goal.update({
        where: { id: goalId },
        data: { currentValue: newValue, status },
      })

      if (data.createExpense !== false && data.personId) {
        const dateParts = dateStr.split('-')
        const expMonth = parseInt(dateParts[1])
        const expYear = parseInt(dateParts[0])
        await tx.expense.create({
          data: {
            description: `Investimento — ${goal.description}`,
            value: data.value,
            categoryName: 'Investimento',
            type: 'variable',
            date: contributionDate,
            month: expMonth,
            year: expYear,
            personId: data.personId,
            status: 'PAID',
          },
        })
      }

      return [contrib]
    })

    const updated = await prisma.goal.findUnique({
      where: { id: goalId },
      include: { contributions: { orderBy: { date: 'desc' } } },
    })

    return { contribution, goal: updated }
  }
}
