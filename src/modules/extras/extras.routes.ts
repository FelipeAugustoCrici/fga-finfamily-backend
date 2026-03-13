import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { ExtrasController } from './extras.controller'
import { createExtraSchema } from './dtos/create-extra.schema'
import { listExtrasQuerySchema } from '@/modules/extras/dtos/list-extras.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function extrasRoutes(app: FastifyZodInstance) {
  const controller: ExtrasController = new ExtrasController()

  app.post('/', { schema: { body: createExtraSchema } }, (req, reply) =>
    controller.createExtra(req, reply),
  )

  app.put('/:id', (req, reply) => controller.updateExtra(req, reply))

  app.get('/', { schema: { querystring: listExtrasQuerySchema } }, (req, reply) =>
    controller.listExtras(req, reply),
  )
}
