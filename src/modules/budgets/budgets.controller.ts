import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateBudgetsInput } from './dtos/create-budgets.schema'
import { BudgetsService } from './budgets.service'
import { MonthYearQuery } from '@/shared/schemas/month-year-query.schema'

export class BudgetsController {
  private service: BudgetsService = new BudgetsService()

  async upsertBudget(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.upsertBudget(req.body as CreateBudgetsInput)
    return reply.status(201).send(result)
  }

  async listBudgets(req: FastifyRequest, reply: FastifyReply) {
    const { month, year } = req.query as MonthYearQuery
    const result = await this.service.listBudgets(month, year)
    return reply.send(result)
  }

  async getBudgetById(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getBudgetById(id)
    return reply.send(result)
  }

  async deleteBudget(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.deleteBudget(id)
    return reply.status(204).send()
  }
}