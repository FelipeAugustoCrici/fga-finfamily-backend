import z from 'zod'

export const updateExpenseSchema = z.object({
  description: z.string().min(1),
  value: z.coerce.number().positive(),
  categoryName: z.string().min(1),
  categoryId: z.uuid().optional(),
  date: z.string(),
  personId: z.uuid(),
  status: z.enum(['PENDING', 'PAID', 'OVERDUE']).optional(),
})

export type UpdateExpenseInput = z.infer<typeof updateExpenseSchema>
