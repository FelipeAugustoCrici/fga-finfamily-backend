import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { createFamilySchema } from './dtos/create-family.schema'
import { FamiliesController } from './families.controller'
import { paramIdSchema } from '@/shared/schemas/param-id.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function familiesRoutes(app: FastifyZodInstance) {
  const controller: FamiliesController = new FamiliesController()

  app.post('', { schema: { body: createFamilySchema } }, (req, reply) =>
    controller.createFamily(req, reply),
  )
  app.get('', (req, reply) => controller.getFamilies(req, reply))
  
  app.get('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.getFamilyById(req, reply),
  )
  
  app.put('/:id', { schema: { body: createFamilySchema, params: paramIdSchema } }, (req, reply) =>
    controller.updateFamily(req, reply),
  )
  
  app.delete('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.deleteFamily(req, reply),
  )
}
