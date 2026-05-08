import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminDeleteUserCommand,
  AdminGetUserCommand,
  AdminSetUserPasswordCommand,
  MessageActionType,
} from '@aws-sdk/client-cognito-identity-provider'

const client = new CognitoIdentityProviderClient({
  region: process.env.COGNITO_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
  },
})

const USER_POOL_ID = process.env.COGNITO_USER_POOL_ID || 'us-east-1_DVBcZf2hV'

export const cognitoService = {
  async createUser(params: {
    email: string
    name: string
    temporaryPassword?: string
  }): Promise<string> {
    const command = new AdminCreateUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: params.email,
      TemporaryPassword: params.temporaryPassword,
      UserAttributes: [
        { Name: 'email', Value: params.email },
        { Name: 'email_verified', Value: 'true' },
        { Name: 'name', Value: params.name },
      ],
      MessageAction: params.temporaryPassword
        ? MessageActionType.SUPPRESS
        : undefined,
      DesiredDeliveryMediums: params.temporaryPassword ? [] : ['EMAIL'],
    })

    const result = await client.send(command)
    const sub = result.User?.Attributes?.find((a) => a.Name === 'sub')?.Value

    if (!sub) throw new Error('Cognito user created but sub not found')

    return sub
  },

  async deleteUser(email: string): Promise<void> {
    const command = new AdminDeleteUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: email,
    })
    await client.send(command)
  },

  async userExists(email: string): Promise<boolean> {
    try {
      const command = new AdminGetUserCommand({
        UserPoolId: USER_POOL_ID,
        Username: email,
      })
      await client.send(command)
      return true
    } catch {
      return false
    }
  },

  /**
   * Redefine a senha temporária de um usuário que ainda não completou o primeiro login
   * (status FORCE_CHANGE_PASSWORD). Isso permite que o fluxo de "esqueci minha senha"
   * funcione corretamente, pois o Cognito não envia código de reset para usuários
   * nesse estado.
   */
  async resetTemporaryPassword(email: string, newTemporaryPassword: string): Promise<void> {
    const command = new AdminSetUserPasswordCommand({
      UserPoolId: USER_POOL_ID,
      Username: email,
      Password: newTemporaryPassword,
      Permanent: false, // mantém o status FORCE_CHANGE_PASSWORD para forçar troca no login
    })
    await client.send(command)
  },

  /**
   * Reenvia o email de convite do Cognito para um usuário existente.
   * Útil quando o usuário foi criado com senha temporária manual e nunca recebeu email.
   */
  async resendInvite(email: string, name: string): Promise<void> {
    const command = new AdminCreateUserCommand({
      UserPoolId: USER_POOL_ID,
      Username: email,
      MessageAction: MessageActionType.RESEND,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'email_verified', Value: 'true' },
        { Name: 'name', Value: name },
      ],
      DesiredDeliveryMediums: ['EMAIL'],
    })
    await client.send(command)
  },
}
