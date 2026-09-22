import z from 'zod'

export const createPurchaseSchema = z.object({
  creditCardId: z.string(),
  familyId: z.string().optional(),
  ownerId: z.string().optional(),
  categoryId: z.string().optional(),
  categoryName: z.string().optional(),
  description: z.string().min(1),
  purchaseDate: z.string(), // ISO date string
  totalAmount: z.number().positive(),
  installments: z.number().int().min(1).max(24).default(1),
  observation: z.string().optional(),
  isShared: z.boolean().optional(),
})

export type CreatePurchaseInput = z.infer<typeof createPurchaseSchema>
