import { FastifyReply, FastifyRequest } from 'fastify'
import { DeleteRecordsParams, UpdateRecordsParams } from './dtos'
import { CreateFamilyInput, createFamilySchema } from '@/modules/families/dtos/create-family.schema'
import { CreateIncomeInput, createIncomeSchema } from '@/modules/incomes/dtos'
import { CreateExpenseInput, createExpenseSchema } from '@/modules/expenses/dtos'
import { RecordsService } from './records.service'

export class RecordsController {
  private service: RecordsService = new RecordsService()

  async deleteRecord(req: FastifyRequest, reply: FastifyReply) {
    const { type, id } = req.params as DeleteRecordsParams
    const userId = req.user.sub
    await this.service.deleteRecord(type, id, userId)
    return reply.status(204).send()
  }

  async updateRecord(req: FastifyRequest, reply: FastifyReply) {
    const { type, id } = req.params as UpdateRecordsParams
    const userId = req.user.sub

    let validatedData = req.body as CreateFamilyInput | CreateIncomeInput | CreateExpenseInput
    if (type === 'salaries') validatedData = createFamilySchema.parse(req.body)
    if (type === 'incomes' || type === 'extras') validatedData = createIncomeSchema.parse(req.body)
    if (type === 'expenses') validatedData = createExpenseSchema.parse(req.body)

    const result = await this.service.updateRecord(type, id, validatedData, userId)
    return reply.send(result)
  }
}
