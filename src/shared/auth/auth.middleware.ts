import { CognitoJwtVerifier } from 'aws-jwt-verify'
import { FastifyReply, FastifyRequest } from 'fastify'

const verifier = CognitoJwtVerifier.create({
  userPoolId: process.env.COGNITO_USER_POOL_ID || 'us-east-1_DVBcZf2hV',
  tokenUse: 'access',
  clientId: process.env.COGNITO_CLIENT_ID || '36ep258ahtn11e2bd4c3hihmpv',
})

declare module 'fastify' {
  interface FastifyRequest {
    user: {
      sub: string
      username: string
      email?: string
      groups: string[]
    }
  }
}

export async function authMiddleware(req: FastifyRequest, reply: FastifyReply) {
  try {
    const authHeader = req.headers.authorization

    if (!authHeader) {
      return reply.status(401).send({
        message: 'Usuario nao autenticado. Por favor, faca login novamente.',
      })
    }

    const token = authHeader.replace('Bearer ', '')
    const payload = await verifier.verify(token)

    req.user = {
      sub: payload.sub,
      username: (payload as any).username || payload.sub,
      email: (payload as any).email,
      groups: (payload as any)['cognito:groups'] || [],
    }
  } catch (err) {
    req.log.error(err)
    return reply.status(401).send({
      message: 'Nao foi possivel validar seu usuario. Verifique seu acesso.',
    })
  }
}
