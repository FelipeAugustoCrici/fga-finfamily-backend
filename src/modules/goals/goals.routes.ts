import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { createGoalSchema } from './dtos/create-goal.schema'
import { GoalsController } from './goals.controller'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export function goalsRoutes(app: FastifyZodInstance) {
  const controller: GoalsController = new GoalsController()

  app.post('/', { schema: { body: createGoalSchema } }, (req, reply) =>
    controller.createGoal(req, reply),
  )
  app.get('/', (req, reply) => controller.getGoals(req, reply))
  app.get('/:id', (req, reply) => controller.getGoalById(req, reply))
  app.put('/:id', (req, reply) => controller.updateGoal(req, reply))
  app.delete('/:id', (req, reply) => controller.deleteGoal(req, reply))
}
