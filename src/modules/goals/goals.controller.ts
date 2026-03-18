import { FastifyReply, FastifyRequest } from 'fastify'
import { CreateGoalInput, AddContributionInput } from './dtos/create-goal.schema'
import { GoalsService } from './goals.service'

export class GoalsController {
  private service: GoalsService = new GoalsService()

  async createGoal(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.createGoal(req.body as CreateGoalInput)
    return reply.status(201).send(result)
  }

  async getGoals(req: FastifyRequest, reply: FastifyReply) {
    const { familyId } = req.query as { familyId?: string }
    const result = await this.service.listGoals(familyId)
    return reply.send(result)
  }

  async getGoalById(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getGoalById(id)
    return reply.send(result)
  }

  async deleteGoal(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.deleteGoal(id)
    return reply.status(204).send()
  }

  async updateGoal(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const { currentValue } = req.body as { currentValue: number }
    const result = await this.service.updateGoal(id, currentValue)
    return reply.send(result)
  }

  async addContribution(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.addContribution(id, req.body as AddContributionInput)
    return reply.status(201).send(result)
  }
}
