import z from 'zod'

export const createPersonSchema = z.object({
  name: z.string().min(1),
  familyId: z.uuid().optional(),
  phone: z.string().optional(),
  email: z.email().optional(),
  cpf: z.string().optional(),
  birthDate: z.string().optional(),
  hasAccess: z.boolean().optional().default(false),
  temporaryPassword: z
    .string()
    .min(8, 'A senha deve ter no mínimo 8 caracteres')
    .regex(/[a-z]/, 'A senha deve conter pelo menos uma letra minúscula')
    .regex(/[A-Z]/, 'A senha deve conter pelo menos uma letra maiúscula')
    .regex(/[0-9]/, 'A senha deve conter pelo menos um número')
    .regex(/[^a-zA-Z0-9]/, 'A senha deve conter pelo menos um caractere especial')
    .optional(),
})

export type CreatePersonInput = z.infer<typeof createPersonSchema>
export type CreatePersonData = CreatePersonInput & { userId: string }
