import { FastifyReply, FastifyRequest } from 'fastify'
import { DeleteRecordsParams, UpdateRecordsParams } from './dtos'
import { CreateFamilyInput, createFamilySchema } from '@/modules/families/dtos/create-family.schema'
import { CreateIncomeInput, createIncomeSchema } from '@/modules/incomes/dtos'
import { CreateExpenseInput, createExpenseSchema } from '@/modules/expenses/dtos'
import { RecordsService } from './records.service'
import { RecordsResumoService } from './records-resumo.service'
import { RecordsResumoQuery } from './dtos/records-resumo-query.schema'

export class RecordsController {
  private service: RecordsService = new RecordsService()
  private resumoService: RecordsResumoService = new RecordsResumoService()

  async getResumo(req: FastifyRequest, reply: FastifyReply) {
    const { mes, ano, familiaId, responsavelId, categoriaId, status } =
      req.query as RecordsResumoQuery
    const userId = req.user.sub
    const result = await this.resumoService.getResumo({
      mes,
      ano,
      familiaId,
      userId,
      responsavelId,
      categoriaId,
      status,
    })
    return reply.send(result)
  }

  async deleteRecord(req: FastifyRequest, reply: FastifyReply) {
    const { type, id } = req.params as DeleteRecordsParams
    await this.service.deleteRecord(type, id)
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
