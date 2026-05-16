import { prisma } from '@/lib/prisma'

export interface RecordsResumoParams {
  mes: number
  ano: number
  familiaId: string
  responsavelId?: string
  categoriaId?: string
  status?: string
}

export class RecordsResumoRepository {
  async getResumo(params: RecordsResumoParams) {
    const { mes, ano, familiaId, responsavelId, categoriaId, status } = params

    const prevMes = mes === 1 ? 12 : mes - 1
    const prevAno = mes === 1 ? ano - 1 : ano

    // Filtros base para despesas
    const expenseWhere = {
      person: {
        familyId: familiaId,
        ...(responsavelId ? { id: responsavelId } : {}),
      },
      month: mes,
      year: ano,
      is_deleted: false,
      ...(categoriaId ? { categoryId: categoriaId } : {}),
      ...(status ? { status } : {}),
    }

    // Filtros para mês anterior (sem filtro de status para comparação)
    const prevExpenseWhere = {
      person: { familyId: familiaId },
      month: prevMes,
      year: prevAno,
      is_deleted: false,
      status: 'PAID',
    }

    // Filtros para entradas (incomes + extras)
    const incomeWhere = {
      person: {
        familyId: familiaId,
        ...(responsavelId ? { id: responsavelId } : {}),
      },
      month: mes,
      year: ano,
      is_deleted: false,
    }

    const extraWhere = {
      person: {
        familyId: familiaId,
        ...(responsavelId ? { id: responsavelId } : {}),
      },
      month: mes,
      year: ano,
      is_deleted: false,
    }

    // Executa todas as queries em paralelo
    const [
      expensesByStatus,
      recorrentes,
      prevPagas,
      incomes,
      extras,
      expensesByPerson,
      incomesByPerson,
      extrasByPerson,
    ] = await Promise.all([
      // Agregação de despesas por status
      prisma.expense.groupBy({
        by: ['status'],
        where: expenseWhere,
        _sum: { value: true },
        _count: { id: true },
      }),

      // Total de recorrentes
      prisma.expense.aggregate({
        where: { ...expenseWhere, recurringId: { not: null } },
        _sum: { value: true },
        _count: { id: true },
      }),

      // Total pago mês anterior (para variação)
      prisma.expense.aggregate({
        where: prevExpenseWhere,
        _sum: { value: true },
      }),

      // Entradas (incomes)
      prisma.income.aggregate({
        where: incomeWhere,
        _sum: { value: true },
      }),

      // Extras
      prisma.extraIncome.aggregate({
        where: extraWhere,
        _sum: { value: true },
      }),

      // Despesas agrupadas por pessoa
      prisma.expense.groupBy({
        by: ['personId'],
        where: { ...expenseWhere },
        _sum: { value: true },
      }),

      // Incomes agrupados por pessoa
      prisma.income.groupBy({
        by: ['personId'],
        where: incomeWhere,
        _sum: { value: true },
      }),

      // Extras agrupados por pessoa
      prisma.extraIncome.groupBy({
        by: ['personId'],
        where: extraWhere,
        _sum: { value: true },
      }),
    ])

    // Busca nomes das pessoas envolvidas
    const personIds = [
      ...new Set([
        ...expensesByPerson.map((e) => e.personId),
        ...incomesByPerson.map((i) => i.personId),
        ...extrasByPerson.map((e) => e.personId),
      ]),
    ]

    const persons =
      personIds.length > 0
        ? await prisma.person.findMany({
            where: { id: { in: personIds } },
            select: { id: true, name: true },
          })
        : []

    const personMap = new Map(persons.map((p) => [p.id, p.name]))

    // Processa despesas por status
    const statusMap = new Map(
      expensesByStatus.map((s) => [
        s.status,
        { valor: s._sum.value ?? 0, quantidade: s._count.id },
      ]),
    )

    const pagas = statusMap.get('PAID') ?? { valor: 0, quantidade: 0 }
    const pendentes = statusMap.get('PENDING') ?? { valor: 0, quantidade: 0 }
    const atrasadas = statusMap.get('OVERDUE') ?? { valor: 0, quantidade: 0 }

    const totalSaidas = expensesByStatus.reduce((s, e) => s + (e._sum.value ?? 0), 0)
    const totalEntradas = (incomes._sum.value ?? 0) + (extras._sum.value ?? 0)

    // Calcula variação do total pago vs mês anterior
    const prevPagasValor = prevPagas._sum.value ?? 0
    const variacaoPago =
      prevPagasValor > 0 ? ((pagas.valor - prevPagasValor) / prevPagasValor) * 100 : null

    const percentualPago = totalSaidas > 0 ? (pagas.valor / totalSaidas) * 100 : 0

    // Monta responsáveis
    const responsaveisMap = new Map<string, { nome: string; entradas: number; saidas: number }>()

    incomesByPerson.forEach((i) => {
      const id = i.personId
      const entry = responsaveisMap.get(id) ?? {
        nome: personMap.get(id) ?? id,
        entradas: 0,
        saidas: 0,
      }
      entry.entradas += i._sum.value ?? 0
      responsaveisMap.set(id, entry)
    })

    extrasByPerson.forEach((e) => {
      const id = e.personId
      const entry = responsaveisMap.get(id) ?? {
        nome: personMap.get(id) ?? id,
        entradas: 0,
        saidas: 0,
      }
      entry.entradas += e._sum.value ?? 0
      responsaveisMap.set(id, entry)
    })

    expensesByPerson.forEach((e) => {
      const id = e.personId
      const entry = responsaveisMap.get(id) ?? {
        nome: personMap.get(id) ?? id,
        entradas: 0,
        saidas: 0,
      }
      entry.saidas += e._sum.value ?? 0
      responsaveisMap.set(id, entry)
    })

    return {
      totalPago: {
        valor: pagas.valor,
        quantidade: pagas.quantidade,
        percentual: percentualPago,
        variacao: variacaoPago,
      },
      totalPendente: {
        valor: pendentes.valor,
        quantidade: pendentes.quantidade,
      },
      totalAtrasado: {
        valor: atrasadas.valor,
        quantidade: atrasadas.quantidade,
      },
      entradas: totalEntradas,
      saidas: totalSaidas,
      saldoLiquido: totalEntradas - totalSaidas,
      recorrentes: {
        valor: recorrentes._sum.value ?? 0,
        quantidade: recorrentes._count.id,
      },
      responsaveis: Array.from(responsaveisMap.entries()).map(([id, v]) => ({
        id,
        nome: v.nome,
        entradas: v.entradas,
        saidas: v.saidas,
      })),
    }
  }
}
