import z from 'zod'

export const updatePersonSchema = z.object({
  name: z.string().min(1).optional(),
  phone: z.string().optional(),
  email: z.email().optional().or(z.literal('')),
  cpf: z.string().optional(),
  birthDate: z.string().optional(),
})

export type UpdatePersonInput = z.infer<typeof updatePersonSchema>
