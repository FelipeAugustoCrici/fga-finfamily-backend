import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateCreditCardInput } from './dtos/create-credit-card.schema'
import { CreditCardsService } from './credit-cards.service'

export class CreditCardsController {
  private service: CreditCardsService = new CreditCardsService()

  async createCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.createCreditCard(req.body as CreateCreditCardInput)
    return reply.status(201).send(result)
  }

  async getCreditCards(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.listCreditCards()
    return reply.send(result)
  }

  async getCreditCardById(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getCreditCardById(id)
    return reply.send(result)
  }

  async updateCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.updateCreditCard(id, req.body as any)
    return reply.send(result)
  }

  async deleteCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.deleteCreditCard(id)
    return reply.status(204).send()
  }
}
