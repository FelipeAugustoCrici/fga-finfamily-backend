import { FastifyRequest, FastifyReply } from 'fastify'
import { TelegramService } from './telegram.service'
import type { TelegramUpdate } from './telegram.types'

export class TelegramController {
  private service = new TelegramService()

  async webhook(req: FastifyRequest, reply: FastifyReply) {
    const secret = process.env.TELEGRAM_WEBHOOK_SECRET

    if (secret) {
      const incoming = req.headers['x-telegram-bot-api-secret-token']
      if (incoming !== secret) {
        req.log.warn({ incoming }, 'Telegram webhook: secret inválido')
        return reply.status(403).send({ message: 'Forbidden' })
      }
    }

    const update = req.body as TelegramUpdate
    req.log.info({ update_id: update.update_id }, 'Telegram update recebido')

    reply.status(200).send({ ok: true })

    try {
      await this.service.handleUpdate(update)
    } catch (err) {
      req.log.error(err, 'Erro ao processar update do Telegram')
    }
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
