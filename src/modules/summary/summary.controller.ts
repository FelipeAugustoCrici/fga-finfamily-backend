import { FastifyReply, FastifyRequest } from 'fastify'
import { MonthYearQuery } from '@/shared/schemas/month-year-query.schema'
import { SummaryService } from './summary.service'

export class SummaryController {
  private service: SummaryService = new SummaryService()

  async getSummary(req: FastifyRequest, reply: FastifyReply) {
    const { month, year } = req.query as MonthYearQuery
    const userId = req.user.sub
    const result = await this.service.getSummary(month, year, userId)
    return reply.send(result)
  }
}
