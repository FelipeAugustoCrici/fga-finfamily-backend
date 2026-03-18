import { GoalsRepository } from '@/modules/goals/goals.repository'
import { CreateGoalInput, AddContributionInput } from './dtos/create-goal.schema'

export class GoalsService {
  private repository: GoalsRepository = new GoalsRepository()

  async createGoal(data: CreateGoalInput) {
    return this.repository.createGoal({
      ...data,
      deadline: data.deadline ? new Date(data.deadline) : undefined,
    })
  }

  async listGoals(familyId?: string) {
    return this.repository.getGoals(familyId)
  }

  async getGoalById(id: string) {
    return this.repository.getGoalById(id)
  }

  async updateGoal(id: string, currentValue: number) {
    return this.repository.updateGoal(id, { currentValue })
  }

  async deleteGoal(id: string) {
    return this.repository.deleteGoal(id)
  }

  async addContribution(goalId: string, data: AddContributionInput) {
    return this.repository.addContribution(goalId, {
      value: data.value,
      date: data.date ? new Date(data.date) : new Date(),
      observation: data.observation,
      personId: data.personId,
      createExpense: data.createExpense,
    })
  }
}
