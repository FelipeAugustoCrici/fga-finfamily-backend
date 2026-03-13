import { FastifyReply, FastifyRequest } from 'fastify'
import { z } from 'zod'
import { SalariesService } from '@/modules/salaries/salaries.service'

export class SalariesController {
  private service: SalariesService = new SalariesService()

  async createSalary(request: FastifyRequest, reply: FastifyReply) {
    const data = z
      .object({
        personId: z.uuid(),
        value: z.coerce.number().min(0),
        month: z.coerce.number().int().min(1).max(12),
        year: z.coerce.number().int().min(2000),
      })
      .parse(request.body)
    const result = await this.service.saveSalary(data)
    return reply.status(201).send(result)
  }

  async getSalary(request: FastifyRequest, reply: FastifyReply) {
    const { month, year, personId } = z
      .object({
        month: z.coerce.number().int().min(1).max(12),
        year: z.coerce.number().int().min(2000),
        personId: z.uuid(),
      })
      .parse(request.query)
    const result = await this.service.listSalaries(personId, month, year)
    return reply.send(result || {})
  }
}
