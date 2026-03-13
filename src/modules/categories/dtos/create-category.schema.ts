import { z } from 'zod'

export const createCategorySchema = z.object({
  name: z.string().min(1),
  type: z.enum(['income', 'expense']).optional(),
  familyId: z.string().uuid().optional(),
})

export type CreateCategoryInput = z.infer<typeof createCategorySchema>
