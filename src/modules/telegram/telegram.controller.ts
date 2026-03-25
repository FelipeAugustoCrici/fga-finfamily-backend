import { FastifyRequest, FastifyReply } from 'fastify'
import { TelegramService } from './telegram.service'
import type { TelegramUpdate } from './telegram.types'

export class TelegramController {
  private service = new TelegramService()

  async webhook(req: FastifyRequest, reply: FastifyReply) {
    console.log('[TELEGRAM] ✅ Webhook hit')
    console.log('[TELEGRAM] Headers:', JSON.stringify(req.headers, null, 2))
    console.log('[TELEGRAM] Body:', JSON.stringify(req.body, null, 2))

    const secret = process.env.TELEGRAM_WEBHOOK_SECRET
    console.log('[TELEGRAM] TELEGRAM_WEBHOOK_SECRET configurado:', !!secret, '| valor:', secret ?? 'VAZIO')
    console.log('[TELEGRAM] TELEGRAM_BOT_TOKEN configurado:', !!process.env.TELEGRAM_BOT_TOKEN)

    if (secret) {
      const incoming = req.headers['x-telegram-bot-api-secret-token']
      console.log('[TELEGRAM] Secret recebido no header:', incoming ?? 'AUSENTE')
      if (incoming !== secret) {
        console.log('[TELEGRAM] ❌ Secret inválido — retornando 403')
        return reply.status(403).send({ message: 'Forbidden' })
      }
    } else {
      console.log('[TELEGRAM] Secret não configurado — pulando validação')
    }

    const update = req.body as TelegramUpdate
    console.log('[TELEGRAM] update_id:', update?.update_id)

    reply.status(200).send({ ok: true })
    console.log('[TELEGRAM] ✅ 200 enviado ao Telegram')

    try {
      await this.service.handleUpdate(update)
      console.log('[TELEGRAM] ✅ handleUpdate concluído')
    } catch (err) {
      console.error('[TELEGRAM] ❌ Erro no handleUpdate:', err)
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
