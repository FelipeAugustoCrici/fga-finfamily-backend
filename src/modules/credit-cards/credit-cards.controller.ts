import { FastifyReply, FastifyRequest } from 'fastify'
import { CreditCardsService } from './credit-cards.service'
import { CreateCreditCardInput } from './dtos/create-credit-card.schema'
import { CreatePurchaseInput } from './dtos/create-purchase.schema'
import { PayInvoiceInput } from './dtos/pay-invoice.schema'

export class CreditCardsController {
  private service = new CreditCardsService()

  async createCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const result = await this.service.createCreditCard(req.body as CreateCreditCardInput)
    return reply.status(201).send(result)
  }

  async getCreditCards(req: FastifyRequest, reply: FastifyReply) {
    const { familyId } = req.query as { familyId?: string }
    const result = await this.service.listCreditCards(familyId)
    return reply.send(result)
  }

  async getCreditCardById(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getCreditCardById(id)
    return reply.send(result)
  }

  async updateCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.updateCreditCard(id, req.body as Partial<CreateCreditCardInput>)
    return reply.send(result)
  }

  async deleteCreditCard(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    await this.service.deleteCreditCard(id)
    return reply.status(204).send()
  }

  // Purchases
  async createPurchase(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const result = await this.service.createPurchase(req.body as CreatePurchaseInput, userId)
    return reply.status(201).send(result)
  }

  async getPurchasesByCard(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getPurchasesByCard(id)
    return reply.send(result)
  }

  async deletePurchase(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const { id } = req.params as { id: string }
    await this.service.deletePurchase(id, userId)
    return reply.status(204).send()
  }

  // Invoices
  async getInvoices(req: FastifyRequest, reply: FastifyReply) {
    const { id } = req.params as { id: string }
    const result = await this.service.getInvoices(id)
    return reply.send(result)
  }

  async getInvoiceById(req: FastifyRequest, reply: FastifyReply) {
    const { invoiceId } = req.params as { invoiceId: string }
    const result = await this.service.getInvoiceById(invoiceId)
    return reply.send(result)
  }

  async payInvoice(req: FastifyRequest, reply: FastifyReply) {
    const { invoiceId } = req.params as { invoiceId: string }
    const { paidAmount } = req.body as PayInvoiceInput
    const result = await this.service.payInvoice(invoiceId, paidAmount)
    return reply.send(result)
  }

  async getAllInvoicesByFamily(req: FastifyRequest, reply: FastifyReply) {
    const { familyId } = req.params as { familyId: string }
    const result = await this.service.getAllInvoicesByFamily(familyId)
    return reply.send(result)
  }

  async getCreditCardSummaryByFamily(req: FastifyRequest, reply: FastifyReply) {
    const { familyId } = req.params as { familyId: string }
    const { month, year } = req.query as { month: string; year: string }
    const result = await this.service.getCreditCardSummaryByFamily(
      familyId,
      Number(month),
      Number(year),
    )
    return reply.send(result)
  }
}
