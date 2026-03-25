import type { ParsedRecord } from './telegram.types'

const EXPENSE_TRIGGERS = ['paguei', 'gastei', 'comprei', 'enviei', 'transferi', 'debitei']
const INCOME_TRIGGERS = ['recebi', 'ganhei', 'entrou']
const SALARY_KEYWORDS = ['salario', 'salário', 'salario mensal', 'pagamento mensal']
const EXTRA_KEYWORDS = ['bonus', 'bônus', 'extra', 'freelance', 'freela', 'comissão', 'comissao']

const CATEGORY_MAP: Record<string, string[]> = {
  Alimentação: ['mercado', 'supermercado', 'restaurante', 'lanche', 'comida', 'ifood', 'delivery', 'padaria'],
  Transporte: ['uber', 'gasolina', 'combustivel', 'combustível', 'onibus', 'ônibus', 'metro', 'metrô', 'passagem', 'estacionamento'],
  Saúde: ['farmacia', 'farmácia', 'remedio', 'remédio', 'medico', 'médico', 'consulta', 'exame', 'hospital', 'plano de saude'],
  Internet: ['internet', 'wifi', 'banda larga', 'net', 'vivo', 'claro', 'tim', 'oi'],
  Moradia: ['aluguel', 'condominio', 'condomínio', 'agua', 'água', 'luz', 'energia', 'gas', 'gás', 'iptu'],
  Lazer: ['cinema', 'netflix', 'spotify', 'streaming', 'show', 'viagem', 'hotel', 'passeio'],
  Educação: ['escola', 'faculdade', 'curso', 'livro', 'mensalidade'],
  Vestuário: ['roupa', 'sapato', 'tenis', 'tênis', 'calçado'],
  Salário: [...SALARY_KEYWORDS],
  'Renda Extra': [...EXTRA_KEYWORDS],
}

function guessCategory(description: string, type: 'expense' | 'income' | 'extra'): string {
  const lower = description.toLowerCase()

  if (type === 'income') return 'Salário'
  if (type === 'extra') return 'Renda Extra'

  for (const [category, keywords] of Object.entries(CATEGORY_MAP)) {
    if (keywords.some((kw) => lower.includes(kw))) return category
  }

  return 'Outros'
}

function extractValue(text: string): number | null {
  const match = text.match(/(\d+(?:[.,]\d{1,2})?)/)
  if (!match) return null
  return parseFloat(match[1].replace(',', '.'))
}

function normalizeText(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
}

export function parseMessage(text: string): ParsedRecord | null {
  const normalized = normalizeText(text)
  const value = extractValue(normalized)
  if (!value) return null

  const isExpense = EXPENSE_TRIGGERS.some((t) => normalized.startsWith(t))
  const isIncome = INCOME_TRIGGERS.some((t) => normalized.startsWith(t))

  if (!isExpense && !isIncome) return null

  const isSalary = SALARY_KEYWORDS.some((kw) => normalized.includes(normalizeText(kw)))
  const isExtra = EXTRA_KEYWORDS.some((kw) => normalized.includes(normalizeText(kw)))

  let type: 'expense' | 'income' | 'extra'
  if (isExpense) {
    type = 'expense'
  } else if (isSalary) {
    type = 'income'
  } else {
    type = 'extra'
  }

  const description = text.trim()
  const categoryName = guessCategory(description, type)

  return { type, value, description, categoryName }
}
