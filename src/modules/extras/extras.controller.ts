import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateExtraInput } from './dtos/create-extra.schema'
import { ExtrasService } from './extras.service'
import { ListExtrasQuerySchema } from './dtos/list-extras.schema'

export class ExtrasController {
  private service: ExtrasService = new ExtrasService()

  async createExtra(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.createExtraIncome({
      ...(req.body as CreateExtraInput),
      userId,
    })
    return reply.status(201).send(result)
  }

  async updateExtra(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as { id: string }
    const result = await this.service.updateExtraIncome(id, req.body as any, userId)
    return reply.status(200).send(result)
  }

  async listExtras(req: FastifyRequest, reply: FastifyReply) {
    const { month, year } = req.query as ListExtrasQuerySchema
    const userId = req.user.sub
    const result = await this.service.listExtras(month, year, userId)
    return reply.send(result)
  }
}
