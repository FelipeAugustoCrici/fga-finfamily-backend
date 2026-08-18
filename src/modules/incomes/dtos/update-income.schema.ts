import z from 'zod'

export const updateIncomeSchema = z.object({
  description: z.string().min(1),
  value: z.coerce.number().positive(),
  date: z.string(),
  personId: z.uuid(),
  type: z.enum(['fixed', 'flex', 'temporary']).optional(),
})

export type UpdateIncomeInput = z.infer<typeof updateIncomeSchema>
