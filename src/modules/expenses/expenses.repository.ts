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
        orderBy: { date: 'desc' },
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
  ) {
    const skip = (page - 1) * limit

    const where = {
      person: { familyId },
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
        orderBy: { date: 'desc' },
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
