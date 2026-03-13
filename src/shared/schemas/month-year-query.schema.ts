import { z } from 'zod'

export const monthYearQuerySchema = z.object({
  month: z.coerce.number().int().min(1).max(12),
  year: z.coerce.number().int().min(1900).max(2100),
})

export type MonthYearQuery = z.infer<typeof monthYearQuerySchema>
