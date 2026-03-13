import { z } from 'zod'

export const paramIdSchema = z.object({
  id: z.uuid(),
})

export type ParamIdInput = z.infer<typeof paramIdSchema>
