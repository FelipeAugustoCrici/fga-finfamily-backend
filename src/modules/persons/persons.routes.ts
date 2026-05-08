import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { PersonsController } from '@/modules/persons/persons.controller'
import { createPersonSchema } from '@/modules/persons/dtos/create-person.schema'
import { updatePersonSchema } from './dtos/update-person.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function personsRoutes(app: FastifyZodInstance) {
  const controller: PersonsController = new PersonsController()

  app.post('/', { schema: { body: createPersonSchema } }, (req, reply) =>
    controller.createPerson(req, reply),
  )

  app.get('/me', (req, reply) => controller.getMe(req, reply))
  app.put('/me', { schema: { body: updatePersonSchema } }, (req, reply) =>
    controller.updateMe(req, reply),
  )
  
  app.delete('/:id', (req, reply) => controller.deletePerson(req, reply))

  app.post('/:id/resend-invite', (req, reply) => controller.resendInvite(req, reply))
}
