import z from 'zod'

export const listIncomesQuerySchema = z.object({
  month: z.coerce.number().int().min(1).max(12),
  year: z.coerce.number().int().min(2000),
  familyId: z.uuid().optional(),
})

export type ListIncomesQuery = z.infer<typeof listIncomesQuerySchema>
