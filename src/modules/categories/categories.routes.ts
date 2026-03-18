import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { CategoriesController } from '@/modules/categories/categories.controller'
import { createCategorySchema } from '@/modules/categories/dtos/create-category.schema'
import { paramIdSchema } from '@/shared/schemas/param-id.schema'
import z from 'zod'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function categoriesRoutes(app: FastifyZodInstance) {
  const controller: CategoriesController = new CategoriesController()

  app.post('/', { schema: { body: createCategorySchema } }, (req, reply) =>
    controller.createCategory(req, reply),
  )
  app.get(
    '/',
    {
      schema: {
        querystring: z.object({
          familyId: z.string().uuid().optional(),
          type: z.enum(['expense', 'income']).optional(),
          page: z.coerce.number().int().positive().optional(),
          limit: z.coerce.number().int().positive().optional(),
        }),
      },
    },
    (req, reply) => controller.listCategories(req, reply),
  )
  app.delete('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.deleteCategory(req, reply),
  )
}
