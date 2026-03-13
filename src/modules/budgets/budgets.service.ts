import { CreateBudgetsInput } from '@/modules/budgets/dtos/create-budgets.schema'
import { BudgetsRepository } from '@/modules/budgets/budgets.repository'

export class BudgetsService {
  private repository: BudgetsRepository = new BudgetsRepository()

  async upsertBudget(data: CreateBudgetsInput) {
    return this.repository.upsertBudget(data)
  }

  async listBudgets(month: number, year: number) {
    return this.repository.listBudgets(month, year)
  }

  async getBudgetById(id: string) {
    return this.repository.getBudgetById(id)
  }

  async deleteBudget(id: string) {
    return this.repository.deleteBudget(id)
  }
}