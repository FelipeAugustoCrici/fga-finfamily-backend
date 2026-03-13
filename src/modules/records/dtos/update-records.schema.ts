import { z } from 'zod'

export const updateRecordsParamsSchema = z.object({
  type: z.enum(['salaries', 'extras', 'incomes', 'expenses']),
  id: z.uuid(),
})

export type UpdateRecordsParams = z.infer<typeof updateRecordsParamsSchema>
