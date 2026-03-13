import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { SalariesController } from '@/modules/salaries/salaries.controller'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function salariesRoutes(app: FastifyZodInstance) {
  const controller: SalariesController = new SalariesController()

  app.post('/', (req, rep) => controller.createSalary(req, rep))
  app.get('/', (req, rep) => controller.getSalary(req, rep))
}
