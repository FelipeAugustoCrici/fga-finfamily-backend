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
  }) {
    const { ...prismaData } = data
    return this.prisma.create({
      data: prismaData,
    })
  }

  async getExpenseById(id: string, userId: string) {
    return this.prisma.findUnique({
      where: { id, person: { userId } },
      include: { recurring: true, category: true, person: { include: { family: true } } },
    })
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
      description: string
      value: number
      categoryName: string
      categoryId?: string
      date: Date
      month: number
      year: number
      personId: string
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
}
