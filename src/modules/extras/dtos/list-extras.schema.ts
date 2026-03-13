import z from 'zod'

export const listExtrasQuerySchema = z.object({
  month: z.coerce.number().int().min(1).max(12),
  year: z.coerce.number().int().min(2000),
})

export type ListExtrasQuerySchema = z.infer<typeof listExtrasQuerySchema>
