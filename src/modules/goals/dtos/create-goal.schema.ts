import z from 'zod'

export const createGoalSchema = z.object({
  description: z.string().min(1),
  type: z.enum(['savings', 'debt', 'purchase', 'investment']).default('savings'),
  targetValue: z.number().positive(),
  currentValue: z.number().min(0).optional(),
  deadline: z.string().optional(),
  familyId: z.string().optional(),
  personId: z.string().optional(),
})

export const addContributionSchema = z.object({
  value: z.number().positive(),
  date: z.string().optional(),
  observation: z.string().optional(),
  personId: z.string().optional(),
  createExpense: z.boolean().optional().default(true),
})

export type CreateGoalInput = z.infer<typeof createGoalSchema>
export type AddContributionInput = z.infer<typeof addContributionSchema>
