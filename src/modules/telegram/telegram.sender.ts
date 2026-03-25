interface InlineButton {
  text: string
  callback_data: string
}

function getBaseUrl() {
  const token = process.env.TELEGRAM_BOT_TOKEN
  if (!token) throw new Error('TELEGRAM_BOT_TOKEN não configurado')
  return `https://api.telegram.org/bot${token}`
}

export async function sendMessage(chatId: string | number, text: string, buttons?: InlineButton[][]) {
  const body: Record<string, unknown> = {
    chat_id: chatId,
    text,
    parse_mode: 'HTML',
  }

  if (buttons) {
    body.reply_markup = { inline_keyboard: buttons }
  }

  const res = await fetch(`${getBaseUrl()}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })

  if (!res.ok) {
    const err = await res.text()
    throw new Error(`Telegram sendMessage failed: ${err}`)
  }

  return res.json()
}

export async function answerCallbackQuery(callbackQueryId: string, text?: string) {
  await fetch(`${getBaseUrl()}/answerCallbackQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ callback_query_id: callbackQueryId, text }),
  })
}
