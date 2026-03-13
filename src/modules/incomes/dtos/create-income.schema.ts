import z from 'zod'

export const createIncomeSchema = z.object({
  description: z.string().min(1),
  value: z.coerce.number().positive(),
  date: z.string(),
  personId: z.uuid(),
  type: z.enum(['fixed', 'flex', 'temporary']),
  isRecurring: z.boolean().optional(),
  durationMonths: z.number().int().min(0).optional(),
})

export type CreateIncomeInput = z.infer<typeof createIncomeSchema>
