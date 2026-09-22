import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { CreditCardsController } from './credit-cards.controller'
import { createCreditCardSchema } from './dtos/create-credit-card.schema'
import { createPurchaseSchema } from './dtos/create-purchase.schema'
import { payInvoiceSchema } from './dtos/pay-invoice.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function creditCardsRoutes(app: FastifyZodInstance) {
  const controller = new CreditCardsController()

  // Cards
  app.post('/', { schema: { body: createCreditCardSchema } }, (req, reply) =>
    controller.createCreditCard(req, reply),
  )
  app.get('/', (req, reply) => controller.getCreditCards(req, reply))
  app.get('/:id', (req, reply) => controller.getCreditCardById(req, reply))
  app.put('/:id', (req, reply) => controller.updateCreditCard(req, reply))
  app.delete('/:id', (req, reply) => controller.deleteCreditCard(req, reply))

  // Purchases
  app.post('/purchases', { schema: { body: createPurchaseSchema } }, (req, reply) =>
    controller.createPurchase(req, reply),
  )
  app.get('/:id/purchases', (req, reply) => controller.getPurchasesByCard(req, reply))
  app.delete('/purchases/:id', (req, reply) => controller.deletePurchase(req, reply))

  // Invoices
  app.get('/:id/invoices', (req, reply) => controller.getInvoices(req, reply))
  app.get('/invoices/:invoiceId', (req, reply) => controller.getInvoiceById(req, reply))
  app.post('/invoices/:invoiceId/pay', { schema: { body: payInvoiceSchema } }, (req, reply) =>
    controller.payInvoice(req, reply),
  )

  // Family-level
  app.get('/family/:familyId/invoices', (req, reply) =>
    controller.getAllInvoicesByFamily(req, reply),
  )
  app.get('/family/:familyId/summary', (req, reply) =>
    controller.getCreditCardSummaryByFamily(req, reply),
  )
}
