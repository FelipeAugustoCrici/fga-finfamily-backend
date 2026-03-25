import { FastifyRequest, FastifyReply } from 'fastify'
import { TelegramService } from './telegram.service'
import type { TelegramUpdate } from './telegram.types'

export class TelegramController {
  private service = new TelegramService()

  async webhook(req: FastifyRequest, reply: FastifyReply) {
    const secret = req.headers['x-telegram-bot-api-secret-token']
    if (secret !== process.env.TELEGRAM_WEBHOOK_SECRET) {
      return reply.status(403).send({ message: 'Forbidden' })
    }

    const update = req.body as TelegramUpdate
    await this.service.handleUpdate(update)
    return reply.status(200).send({ ok: true })
  }

  async generateCode(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const code = await this.service.generateActivationCode(userId)
    return reply.send({ code, expiresInMinutes: 15 })
  }

  async getLinkStatus(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    const status = await this.service.getLinkStatus(userId)
    return reply.send(status)
  }

  async unlink(req: FastifyRequest, reply: FastifyReply) {
    const userId = req.user.sub
    await this.service.unlinkTelegram(userId)
    return reply.send({ message: 'Vínculo removido com sucesso.' })
  }
}
