import { prisma } from '@/lib/prisma'
import _ from 'lodash'

export class ExpensesRepository {
  private prisma = prisma.expense

  async createExpense(data: {
    description: string
    value: number
    categoryName: string
    categoryId?: string
    type: string
    date: Date
    month: number
    year: number
    personId: string
    status?: string
    recurringId?: string
    isShared?: boolean
    originExpenseId?: string
    originMonth?: number
    originYear?: number
  }) {
    const { ...prismaData } = data
    return this.prisma.create({
      data: prismaData,
    })
  }

  async getExpenseById(id: string, userId: string) {
    // First try to find by direct ownership
    const expense = await this.prisma.findUnique({
      where: { id },
      include: { recurring: true, category: true, person: { include: { family: { include: { members: true } } } } },
    })

    if (!expense) return null

    // Allow access if: user owns the person OR the person belongs to the same family as the user
    const isOwner = expense.person.userId === userId
    const isFamilyMember = expense.person.family?.members?.some(m => m.userId === userId)

    if (!isOwner && !isFamilyMember) return null

    return expense
  }

  async deleteExpense(id: string) {
    return this.prisma.update({
      where: { id },
      data: { is_deleted: true, dt_deleted: new Date() },
    })
  }

  async updateExpense(
    id: string,
    data: {
      description?: string
      value?: number
      categoryName?: string
      categoryId?: string
      date?: Date
      month?: number
      year?: number
      personId?: string
      status?: string
      recurringId?: string
      isShared?: boolean
    },
  ) {
    const updateData = _.pickBy(data, (v) => v !== undefined)
    return this.prisma.update({
      where: { id },
      data: updateData,
    })
  }

  async getExpensesByUserId(
    userId: string,
    month: number,
    year: number,
    status?: string,
    page: number = 1,
    limit: number = 10,
  ) {
    const skip = (page - 1) * limit

    const where = {
      person: { userId },
      month,
      year,
      is_deleted: false,
      ...(status && { status }),
    }

    const [data, total] = await Promise.all([
      this.prisma.findMany({
        where,
        include: {
          recurring: true,
          category: true,
        },
        orderBy: { value: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.count({ where }),
    ])

    return {
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    }
  }

  async getExpensesByFamily(
    familyId: string,
    month: number,
    year: number,
    status?: string,
    page: number = 1,
    limit: number = 10,
    filters?: {
      search?: string
      categoryId?: string
      personId?: string
      tipo?: string
      valorMin?: number
      valorMax?: number
      dataInicio?: string
      dataFim?: string
      ordenacao?: string
    },
  ) {
    const skip = (page - 1) * limit

    const where: any = {
      person: {
        familyId,
        ...(filters?.personId ? { id: filters.personId } : {}),
      },
      month,
      year,
      is_deleted: false,
      ...(status ? { status } : {}),
      ...(filters?.categoryId ? { categoryId: filters.categoryId } : {}),
      ...(filters?.tipo === 'recurring'
        ? { recurringId: { not: null } }
        : filters?.tipo === 'fixed'
          ? { type: 'fixed', recurringId: null }
          : filters?.tipo === 'variable'
            ? { type: 'variable' }
            : {}),
      ...(filters?.valorMin != null || filters?.valorMax != null
        ? {
            value: {
              ...(filters.valorMin != null ? { gte: filters.valorMin } : {}),
              ...(filters.valorMax != null ? { lte: filters.valorMax } : {}),
            },
          }
        : {}),
      ...(filters?.dataInicio || filters?.dataFim
        ? {
            date: {
              ...(filters.dataInicio ? { gte: new Date(filters.dataInicio) } : {}),
              ...(filters.dataFim ? { lte: new Date(filters.dataFim) } : {}),
            },
          }
        : {}),
      ...(filters?.search
        ? {
            description: { contains: filters.search, mode: 'insensitive' },
          }
        : {}),
    }

    const orderBy = (() => {
      switch (filters?.ordenacao) {
        case 'antigo':
          return { date: 'asc' as const }
        case 'maior_valor':
          return { value: 'desc' as const }
        case 'menor_valor':
          return { value: 'asc' as const }
        case 'az':
          return { description: 'asc' as const }
        case 'za':
          return { description: 'desc' as const }
        default:
          return { date: 'desc' as const }
      }
    })()

    const [data, total] = await Promise.all([
      this.prisma.findMany({
        where,
        include: { recurring: true, category: true },
        orderBy,
        skip,
        take: limit,
      }),
      this.prisma.count({ where }),
    ])

    return {
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    }
  }

  async getAllExpensesByFamily(familyId: string, month: number, year: number, status?: string) {
    return this.prisma.findMany({
      where: {
        person: { familyId },
        month,
        year,
        is_deleted: false,
        // Parcela de compra no cartão (purchaseId) já nasce paga, mas o
        // dinheiro só sai de verdade da conta quando a fatura é paga — sem
        // esse filtro, a mesma compra conta duas vezes (uma no mês da
        // compra, outra no mês da fatura). Totais usam só a fatura.
        purchaseId: null,
        ...(status && { status }),
      },
      include: {
        recurring: true,
        category: true,
      },
      orderBy: { date: 'desc' },
    })
  }

  async updateStatus(id: string, status: string) {
    return this.prisma.update({
      where: { id },
      data: { status },
    })
  }

  async addPayment(expenseId: string, data: {
    amount: number
    paidAt?: Date
    note?: string
    remainingAfter: number
  }) {
    return prisma.expensePayment.create({
      data: {
        expenseId,
        amount: data.amount,
        paidAt: data.paidAt ?? new Date(),
        note: data.note,
        remainingAfter: data.remainingAfter,
      },
    })
  }

  async getPayments(expenseId: string) {
    return prisma.expensePayment.findMany({
      where: { expenseId },
      orderBy: { paidAt: 'asc' },
    })
  }

  async deletePayment(paymentId: string) {
    return prisma.expensePayment.delete({
      where: { id: paymentId },
    })
  }

  async updatePaidAmount(id: string, paidAmount: number, status: string) {
    return this.prisma.update({
      where: { id },
      data: { paidAmount, status },
    })
  }

  async getExpenseByIdRaw(id: string) {
    return this.prisma.findUnique({
      where: { id },
      include: { payments: { orderBy: { paidAt: 'asc' } }, category: true, person: true },
    })
  }
}
