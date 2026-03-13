import { FastifyReply, FastifyRequest } from 'fastify'
import { CategoriesService } from '@/modules/categories/categories.service'
import { CreateCategoryInput } from './dtos/create-category.schema'
import { ParamIdInput } from '@/shared/schemas/param-id.schema'

export class CategoriesController {
  private service: CategoriesService = new CategoriesService()

  async createCategory(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.createCategory(req.body as CreateCategoryInput)
    return reply.status(201).send(result)
  }

  async listCategories(request: FastifyRequest, reply: FastifyReply) {
    const { familyId } = request.query as { familyId?: string }
    const result = await this.service.listCategories(familyId)
    return reply.send(result)
  }

  async deleteCategory(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as ParamIdInput
    await this.service.deleteCategory(id)
    return reply.status(204).send()
  }
}
