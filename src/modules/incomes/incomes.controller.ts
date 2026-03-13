import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateIncomeInput, ListIncomesQuery } from './dtos'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { ParamIdInput } from '@/shared/schemas/param-id.schema'

export class IncomesController {
  private service: IncomesService = new IncomesService()

  async createIncome(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.createIncome({
      ...(req.body as CreateIncomeInput),
      userId,
    })
    return reply.status(201).send(result)
  }

  async getIncomes(req: FastifyRequest, reply: FastifyReply) {
    const { month, year, familyId } = req.query as ListIncomesQuery
    const userId = req.user.sub
    const result = await this.service.listIncomes(month, year, userId, familyId)
    return reply.send(result)
  }

  async getIncomeById(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as ParamIdInput
    const result = await this.service.getIncomeById(id, userId)
    return reply.send(result)
  }
}
