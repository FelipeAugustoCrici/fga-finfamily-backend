import z from 'zod'

export const createPersonSchema = z.object({
  name: z.string().min(1),
  familyId: z.uuid().optional(),
  phone: z.string().optional(),
  email: z.email().optional(),
  cpf: z.string().optional(),
  birthDate: z.string().optional(),
})

export type CreatePersonInput = z.infer<typeof createPersonSchema>
export type CreatePersonData = CreatePersonInput & { userId: string }
