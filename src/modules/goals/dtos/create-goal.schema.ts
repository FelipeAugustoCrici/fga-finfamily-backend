import z from 'zod'

export const createGoalSchema = z.object({
  description: z.string().min(1),
  targetValue: z.number().positive(),
  currentValue: z.number().min(0).optional(),
  deadline: z.string().optional(),
})

export type CreateGoalInput = z.infer<typeof createGoalSchema>
