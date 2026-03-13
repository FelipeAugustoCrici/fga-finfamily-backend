import z from 'zod'

export const createExtraSchema = z.object({
  description: z.string().min(1),
  value: z.coerce.number().positive(),
  date: z.string(),
  personId: z.uuid(),
})

export type CreateExtraInput = z.infer<typeof createExtraSchema>
