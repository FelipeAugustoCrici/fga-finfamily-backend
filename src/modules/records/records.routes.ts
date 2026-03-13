import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { deleteRecordsParamsSchema, updateRecordsParamsSchema } from './dtos'
import { RecordsController } from './records.controller'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function recordsRoutes(app: FastifyZodInstance) {
  const controller: RecordsController = new RecordsController()

  app.delete('/:type/:id', { schema: { params: deleteRecordsParamsSchema } }, (req, reply) =>
    controller.deleteRecord(req, reply),
  )
  app.patch('/:type/:id', { schema: { params: updateRecordsParamsSchema } }, (req, reply) =>
    controller.updateRecord(req, reply),
  )
}
