import crypto from 'crypto'
import { TelegramRepository } from './telegram.repository'
import { sendMessage, answerCallbackQuery } from './telegram.sender'
import { parseMessage } from './telegram.parser'
import { ExpensesService } from '@/modules/expenses/expenses.service'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { ExtrasService } from '@/modules/extras/extras.service'
import { SummaryService } from '@/modules/summary/summary.service'
import { PersonsService } from '@/modules/persons/persons.service'
import type { TelegramUpdate, ParsedRecord } from './telegram.types'

const ACTIVATION_CODE_TTL_MINUTES = 15

export class TelegramService {
  private repo = new TelegramRepository()
  private expensesService = new ExpensesService()
  private incomesService = new IncomesService()
  private extrasService = new ExtrasService()
  private summaryService = new SummaryService()
  private personsService = new PersonsService()

  async generateActivationCode(userId: string): Promise<string> {
    const code = crypto.randomBytes(4).toString('hex').toUpperCase()
    const expiresAt = new Date(Date.now() + ACTIVATION_CODE_TTL_MINUTES * 60 * 1000)
    await this.repo.upsertActivationCode(userId, code, expiresAt)
    return code
  }

  async getLinkStatus(userId: string) {
    const link = await this.repo.findLinkByUserId(userId)
    return { linked: !!link, username: link?.telegramUsername ?? null }
  }

  async unlinkTelegram(userId: string) {
    await this.repo.deleteLink(userId)
  }

  async handleUpdate(update: TelegramUpdate): Promise<void> {
    if (update.callback_query) {
      await this.handleCallbackQuery(update.callback_query)
      return
    }

    if (!update.message?.text) return

    const { text, chat, from } = update.message
    const chatId = String(chat.id)
    const telegramUserId = String(from?.id ?? '')

    if (text.startsWith('/start')) {
      await this.handleStart(text, chatId, telegramUserId, from?.username)
      return
    }

    const link = await this.repo.findLinkByTelegramUserId(telegramUserId)
    if (!link) {
      await sendMessage(chatId, `Recebi sua mensagem: ${text}\n\n⚠️ Sua conta ainda não está vinculada.\n\nAcesse o sistema, gere um código de ativação e envie <b>/start CODIGO</b> aqui.`)
      return
    }

    if (text === '/ajuda') {
      await this.handleHelp(chatId)
      return
    }

    if (text === '/saldo') {
      await this.handleBalance(chatId, link.userId)
      return
    }

    if (text === '/resumo') {
      await this.handleSummary(chatId, link.userId)
      return
    }

    await this.handleFreeText(text, chatId, link.userId)
  }

  private async handleStart(text: string, chatId: string, telegramUserId: string, username?: string) {
    const parts = text.trim().split(' ')
    const code = parts[1]?.toUpperCase()

    if (!code) {
      await sendMessage(chatId, '👋 Olá! Para vincular sua conta, acesse o sistema e gere um código de ativação.\n\nDepois envie: <b>/start CODIGO</b>')
      return
    }

    const activation = await this.repo.findActivationCodeByCode(code)

    if (!activation) {
      await sendMessage(chatId, '❌ Código inválido. Gere um novo código no sistema e tente novamente.')
      return
    }

    if (new Date() > activation.expiresAt) {
      await sendMessage(chatId, '⏰ Código expirado. Gere um novo código no sistema.')
      return
    }

    const existing = await this.repo.findLinkByTelegramUserId(telegramUserId)
    if (existing) {
      await sendMessage(chatId, '✅ Sua conta já está vinculada.')
      return
    }

    await this.repo.createLink({
      userId: activation.userId,
      telegramUserId,
      telegramChatId: chatId,
      telegramUsername: username,
    })

    await this.repo.deleteActivationCode(activation.userId)

    await sendMessage(chatId, '✅ Conta vinculada com sucesso!\n\nAgora você pode:\n• Lançar despesas: <i>paguei 120 de internet</i>\n• Lançar receitas: <i>recebi 3000 de salário</i>\n• Ver saldo: /saldo\n• Ver resumo: /resumo\n• Ajuda: /ajuda')
  }

  private async handleHelp(chatId: string) {
    await sendMessage(chatId,
      '📖 <b>Como usar o FinFamily Bot</b>\n\n' +
      '<b>Lançar despesa:</b>\n<i>paguei 120 de internet</i>\n<i>gastei 89 no mercado</i>\n\n' +
      '<b>Lançar receita:</b>\n<i>recebi 3000 de salário</i>\n<i>ganhei 500 de freelance</i>\n\n' +
      '<b>Comandos:</b>\n/saldo — saldo do mês atual\n/resumo — resumo financeiro\n/ajuda — esta mensagem'
    )
  }

  private async handleBalance(chatId: string, userId: string) {
    const now = new Date()
    const summary = await this.summaryService.getSummary(now.getMonth() + 1, now.getFullYear(), userId)

    if (!summary) {
      await sendMessage(chatId, '⚠️ Não foi possível obter o saldo. Verifique se sua família está configurada no sistema.')
      return
    }

    const { totals } = summary
    const sign = totals.balance >= 0 ? '+' : ''
    await sendMessage(chatId,
      `💰 <b>Saldo de ${now.toLocaleString('pt-BR', { month: 'long' })}/${now.getFullYear()}</b>\n\n` +
      `📈 Entradas: R$ ${totals.incomes.toFixed(2).replace('.', ',')}\n` +
      `📉 Saídas: R$ ${totals.expenses.toFixed(2).replace('.', ',')}\n` +
      `⚖️ Saldo: <b>${sign}R$ ${totals.balance.toFixed(2).replace('.', ',')}</b>`
    )
  }

  private async handleSummary(chatId: string, userId: string) {
    const now = new Date()
    const summary = await this.summaryService.getSummary(now.getMonth() + 1, now.getFullYear(), userId)

    if (!summary) {
      await sendMessage(chatId, '⚠️ Não foi possível obter o resumo.')
      return
    }

    const { totals } = summary
    await sendMessage(chatId,
      `📊 <b>Resumo de ${now.toLocaleString('pt-BR', { month: 'long' })}/${now.getFullYear()}</b>\n\n` +
      `💼 Salários: R$ ${totals.salary.toFixed(2).replace('.', ',')}\n` +
      `🎁 Extras: R$ ${totals.extras.toFixed(2).replace('.', ',')}\n` +
      `📈 Total entradas: R$ ${totals.incomes.toFixed(2).replace('.', ',')}\n` +
      `📉 Total saídas: R$ ${totals.expenses.toFixed(2).replace('.', ',')}\n` +
      `🏠 Gastos fixos: R$ ${totals.fixedExpenses.toFixed(2).replace('.', ',')}\n` +
      `🛒 Gastos variáveis: R$ ${totals.variableExpenses.toFixed(2).replace('.', ',')}\n\n` +
      `⚖️ <b>Saldo: R$ ${totals.balance.toFixed(2).replace('.', ',')}</b>`
    )
  }

  private async handleFreeText(text: string, chatId: string, userId: string) {
    const parsed = parseMessage(text)

    if (!parsed) {
      await sendMessage(chatId,
        '🤔 Não entendi esse lançamento.\n\nTente algo como:\n<i>paguei 120 de internet</i>\n<i>recebi 3000 de salário</i>\n\nOu use /ajuda para ver exemplos.'
      )
      return
    }

    const typeLabel = parsed.type === 'expense' ? 'Despesa' : parsed.type === 'income' ? 'Receita (salário)' : 'Receita extra'
    const valueFormatted = `R$ ${parsed.value.toFixed(2).replace('.', ',')}`

    const pending = await this.repo.createPendingAction({
      userId,
      telegramChatId: chatId,
      actionType: 'create_record',
      payload: parsed,
    })

    await sendMessage(chatId,
      `📝 Entendi este lançamento:\n\n` +
      `Tipo: <b>${typeLabel}</b>\n` +
      `Valor: <b>${valueFormatted}</b>\n` +
      `Descrição: <b>${parsed.description}</b>\n` +
      `Categoria sugerida: <b>${parsed.categoryName}</b>\n\n` +
      `Confirma?`,
      [[
        { text: '✅ Confirmar', callback_data: `confirm:${pending.id}` },
        { text: '❌ Cancelar', callback_data: `cancel:${pending.id}` },
      ]]
    )
  }

  private async handleCallbackQuery(callbackQuery: NonNullable<TelegramUpdate['callback_query']>) {
    const { id, from, message, data } = callbackQuery
    const chatId = String(message?.chat.id ?? '')
    const telegramUserId = String(from.id)

    if (!data) return

    const [action, pendingId] = data.split(':')

    const link = await this.repo.findLinkByTelegramUserId(telegramUserId)
    if (!link) {
      await answerCallbackQuery(id, 'Conta não vinculada.')
      return
    }

    const pending = await this.repo.findPendingAction(chatId)
    if (!pending || pending.id !== pendingId || pending.status !== 'pending') {
      await answerCallbackQuery(id, 'Ação não encontrada ou já processada.')
      return
    }

    if (action === 'cancel') {
      await this.repo.resolvePendingAction(pendingId, 'cancelled')
      await answerCallbackQuery(id, 'Cancelado.')
      await sendMessage(chatId, '❌ Lançamento cancelado.')
      return
    }

    if (action === 'confirm') {
      await this.repo.resolvePendingAction(pendingId, 'confirmed')
      await answerCallbackQuery(id, 'Processando...')
      await this.persistRecord(pending.payload as ParsedRecord, link.userId, chatId)
    }
  }

  private async persistRecord(parsed: ParsedRecord, userId: string, chatId: string) {
    try {
      const person = await this.personsService.getPersonByUserId(userId)
      if (!person) {
        await sendMessage(chatId, '⚠️ Não foi possível identificar seu perfil no sistema.')
        return
      }

      const today = new Date().toISOString().split('T')[0]

      if (parsed.type === 'expense') {
        await this.expensesService.createExpense({
          description: parsed.description,
          value: parsed.value,
          categoryName: parsed.categoryName,
          type: 'variable',
          date: today,
          personId: person.id,
          status: 'PENDING',
          userId,
        })
      } else if (parsed.type === 'income') {
        await this.incomesService.createIncome({
          description: parsed.description,
          value: parsed.value,
          type: 'flex',
          date: today,
          personId: person.id,
          userId,
        })
      } else {
        await this.extrasService.createExtraIncome({
          description: parsed.description,
          value: parsed.value,
          date: today,
          personId: person.id,
          userId,
        })
      }

      const valueFormatted = `R$ ${parsed.value.toFixed(2).replace('.', ',')}`
      await sendMessage(chatId, `✅ Lançamento salvo!\n\n<b>${parsed.description}</b> — ${valueFormatted}`)
    } catch (err) {
      await sendMessage(chatId, '❌ Erro ao salvar o lançamento. Tente novamente.')
      throw err
    }
  }
}
