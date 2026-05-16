import z from 'zod'

export const listExpensesQuerySchema = z.object({
  month: z.coerce.number().int().min(1).max(12),
  year: z.coerce.number().int().min(2000),
  familyId: z.uuid().optional(),
  status: z.enum(['PENDING', 'PAID', 'OVERDUE']).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  // Novos filtros avançados
  search: z.string().optional(),
  categoryId: z.string().optional(),
  personId: z.string().optional(),
  tipo: z.enum(['fixed', 'variable', 'recurring']).optional(),
  valorMin: z.coerce.number().min(0).optional(),
  valorMax: z.coerce.number().min(0).optional(),
  dataInicio: z.string().optional(),
  dataFim: z.string().optional(),
  ordenacao: z
    .enum(['recente', 'antigo', 'maior_valor', 'menor_valor', 'az', 'za'])
    .optional()
    .default('recente'),
})

export type ListExpensesQuery = z.infer<typeof listExpensesQuerySchema>
