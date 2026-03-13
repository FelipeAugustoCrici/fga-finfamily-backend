import z from 'zod'

export const createCreditCardSchema = z.object({
  name: z.string().min(1),
  limit: z.number().positive(),
  closingDay: z.number().int().min(1).max(31),
  dueDay: z.number().int().min(1).max(31),
})

export type CreateCreditCardInput = z.infer<typeof createCreditCardSchema>
