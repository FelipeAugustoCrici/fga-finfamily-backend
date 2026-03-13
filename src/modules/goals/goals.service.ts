import { GoalsRepository } from '@/modules/goals/goals.repository'

export class GoalsService {
  private repository: GoalsRepository = new GoalsRepository()

  async createGoal(data: { description: string; targetValue: number; deadline?: string }) {
    return this.repository.createGoal({
      ...data,
      deadline: data.deadline ? new Date(data.deadline) : undefined,
    })
  }

  async listGoals() {
    return this.repository.getGoals()
  }

  async updateGoal(id: string, currentValue: number) {
    return this.repository.updateGoal(id, { currentValue })
  }

  async getGoalById(id: string) {
    return this.repository.getGoalById(id)
  }

  async deleteGoal(id: string) {
    return this.repository.deleteGoal(id)
  }
}
