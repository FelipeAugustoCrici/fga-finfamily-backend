import { ExpensesService } from './expenses.service'
import { FastifyReply, FastifyRequest } from 'fastify'
import {
  CreateExpenseInput,
  ListExpensesQuery,
  PatchExpenseStatusInput,
  UpdateExpenseInput,
} from './dtos'
import { ParamIdInput } from '@/shared/schemas/param-id.schema'

export class ExpensesController {
  private service: ExpensesService = new ExpensesService()

  async createExpense(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.createExpense({
      ...(req.body as CreateExpenseInput),
      userId,
    })
    return reply.status(201).send(result)
  }

  async listExpenses(req: FastifyRequest, reply: FastifyReply) {
    const { month, year, familyId, status, page, limit } = req.query as ListExpensesQuery
    const userId = req.user.sub
    const result = await this.service.listExpenses(month, year, userId, familyId, status, page, limit)
    return reply.send(result)
  }

  async getExpenseById(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as ParamIdInput
    const result = await this.service.getExpenseById(id, userId)
    return reply.send(result)
  }

  async updateExpense(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as ParamIdInput
    const result = await this.service.updateExpense(id, req.body as UpdateExpenseInput, userId)
    return reply.send(result)
  }

  async updateStatus(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as ParamIdInput
    const { status } = req.body as PatchExpenseStatusInput
    const result = await this.service.updateStatus(id, status)
    return reply.send(result)
  }

  async deleteExpense(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as ParamIdInput
    await this.service.deleteExpense(id)
    return reply.status(204).send()
  }
}
