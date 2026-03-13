import z from 'zod'

export const createExpenseSchema = z.object({
  description: z.string().min(1),
  value: z.coerce.number().positive(),
  categoryName: z.string().min(1),
  categoryId: z.uuid().optional(),
  type: z.enum(['fixed', 'variable']).default('variable'),
  date: z.string(),
  personId: z.uuid(),
  status: z.enum(['PENDING', 'PAID', 'OVERDUE']).default('PENDING'),
  isCreditCard: z.boolean().optional(),
  creditCardId: z.string().optional(),
  isRecurring: z.boolean().optional(),
  durationMonths: z.number().int().min(0).optional(),
})

export type CreateExpenseInput = z.infer<typeof createExpenseSchema>
