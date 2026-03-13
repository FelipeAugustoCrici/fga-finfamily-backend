import z from 'zod'

export const listExpensesQuerySchema = z.object({
  month: z.coerce.number().int().min(1).max(12),
  year: z.coerce.number().int().min(2000),
  familyId: z.uuid().optional(),
  status: z.enum(['PENDING', 'PAID', 'OVERDUE']).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
})

export type ListExpensesQuery = z.infer<typeof listExpensesQuerySchema>
