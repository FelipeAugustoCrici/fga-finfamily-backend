import { FastifyReply, FastifyRequest } from 'fastify'
import { CreatePersonInput, CreatePersonData } from './dtos/create-person.schema'
import { UpdatePersonInput } from './dtos/update-person.schema'
import { PersonsService } from './persons.service'

export class PersonsController {
  private service: PersonsService = new PersonsService()

  async createPerson(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const data: CreatePersonData = { ...(req.body as CreatePersonInput), userId }
    const result = await this.service.createPerson(data)
    return reply.status(201).send(result)
  }

  async getMe(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.getPersonByUserId(userId)
    return reply.send(result)
  }

  async updateMe(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.updatePerson(userId, req.body as UpdatePersonInput)
    return reply.send(result)
  }

  async deletePerson(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.deletePerson(id)
    return reply.status(204).send()
  }

  async resendInvite(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.resendInvite(id)
    return reply.send({ message: 'Convite reenviado com sucesso' })
  }
}
