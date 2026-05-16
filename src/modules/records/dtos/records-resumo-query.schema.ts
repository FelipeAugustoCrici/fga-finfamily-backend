import { z } from 'zod'

export const recordsResumoQuerySchema = z.object({
  mes: z.coerce.number().int().min(1).max(12),
  ano: z.coerce.number().int().min(1900).max(2100),
  familiaId: z.string().uuid(),
  responsavelId: z.string().uuid().optional(),
  categoriaId: z.string().uuid().optional(),
  status: z.enum(['PAID', 'PENDING', 'OVERDUE']).optional(),
})

export type RecordsResumoQuery = z.infer<typeof recordsResumoQuerySchema>
