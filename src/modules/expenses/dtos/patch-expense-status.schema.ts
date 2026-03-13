import z from 'zod'

export const patchExpenseStatusSchema = z.object({
  status: z.enum(['PENDING', 'PAID', 'OVERDUE']),
})

export type PatchExpenseStatusInput = z.infer<typeof patchExpenseStatusSchema>
