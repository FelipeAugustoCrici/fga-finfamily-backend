import z from 'zod'

export const deleteRecordsParamsSchema = z.object({
  type: z.enum(['salaries', 'extras', 'incomes', 'expenses']),
  id: z.uuid(),
})

export type DeleteRecordsParams = z.infer<typeof deleteRecordsParamsSchema>
