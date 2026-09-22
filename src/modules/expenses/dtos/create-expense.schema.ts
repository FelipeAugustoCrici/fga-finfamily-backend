import z from 'zod'

export const createExpenseSchema = z
  .object({
    description: z.string().min(1),
    value: z.coerce.number().positive(),
    categoryName: z.string().min(1),
    categoryId: z.uuid().optional(),
    type: z.enum(['fixed', 'variable']).default('variable'),
    date: z.string(),
    personId: z.uuid(),
    status: z.enum(['PENDING', 'PAID', 'OVERDUE']).default('PENDING'),
    paymentMethod: z.enum(['account', 'credit_card']).default('account'),
    isCreditCard: z.boolean().optional(),
    creditCardId: z.string().optional(),
    installments: z.coerce.number().int().min(1).max(24).default(1),
    isRecurring: z.boolean().optional(),
    durationMonths: z.number().int().min(0).optional(),
    isShared: z.boolean().optional().default(true),
  })
  .refine((data) => data.paymentMethod !== 'credit_card' || !!data.creditCardId, {
    message: 'Selecione um cartão de crédito',
    path: ['creditCardId'],
  })
  .refine((data) => data.paymentMethod !== 'credit_card' || !data.isRecurring, {
    message: 'Lançamentos pagos no cartão de crédito não podem ser recorrentes',
    path: ['isRecurring'],
  })

export type CreateExpenseInput = z.infer<typeof createExpenseSchema>
