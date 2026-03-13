import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { monthYearQuerySchema } from '@/shared/schemas/month-year-query.schema'
import { SummaryController } from './summary.controller'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function summaryRoutes(app: FastifyZodInstance) {
  const controller: SummaryController = new SummaryController()

  app.get('/', { schema: { querystring: monthYearQuerySchema } }, (req, reply) =>
    controller.getSummary(req, reply),
  )
}
