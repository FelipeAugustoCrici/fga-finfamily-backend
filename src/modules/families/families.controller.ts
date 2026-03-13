import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateFamilyInput } from './dtos/create-family.schema'
import { FamiliesService } from './families.service'

export class FamiliesController {
  private service: FamiliesService = new FamiliesService()

  async createFamily(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.createFamily(req.body as CreateFamilyInput)
    return reply.status(201).send(result)
  }

  async getFamilies(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.listFamilies(userId)
    return reply.send(result)
  }

  async getFamilyById(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as { id: string }
    const result = await this.service.getFamily(id, userId)
    
    if (!result) {
      return reply.status(404).send({ message: 'Família não encontrada' })
    }
    
    return reply.send(result)
  }

  async updateFamily(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as { id: string }
    const result = await this.service.updateFamily(id, req.body as CreateFamilyInput, userId)
    return reply.send(result)
  }

  async deleteFamily(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as { id: string }
    await this.service.deleteFamily(id, userId)
    return reply.status(204).send()
  }
}
