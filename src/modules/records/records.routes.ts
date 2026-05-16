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

import { recordsResumoQuerySchema } from './dtos/records-resumo-query.schema'

export async function recordsRoutes(app: FastifyZodInstance) {
  const controller: RecordsController = new RecordsController()

  app.get('/resumo', { schema: { querystring: recordsResumoQuerySchema } }, (req, reply) =>
    controller.getResumo(req, reply),
  )

  app.delete('/:type/:id', { schema: { params: deleteRecordsParamsSchema } }, (req, reply) =>
    controller.deleteRecord(req, reply),
  )
  app.patch('/:type/:id', { schema: { params: updateRecordsParamsSchema } }, (req, reply) =>
    controller.updateRecord(req, reply),
  )
}
