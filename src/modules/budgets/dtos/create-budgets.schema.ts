import { z } from 'zod'

export const createBudgetsSchema = z.object({
  categoryName: z.string().min(1),
  categoryId: z.uuid().optional(),
  limitValue: z.number().positive(),
  month: z.number().int().min(1).max(12),
  year: z.number().int().min(2000),
})

export type CreateBudgetsInput = z.infer<typeof createBudgetsSchema>
