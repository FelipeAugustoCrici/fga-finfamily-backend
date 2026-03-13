import { prisma } from '@/lib/prisma'

export class CreditCardsRepository {
  private prisma = prisma.creditCard

  async createCreditCard(data: {
    name: string
    limit: number
    closingDay: number
    dueDay: number
  }) {
    return this.prisma.create({ data })
  }

  async getCreditCards() {
    return this.prisma.findMany()
  }

  async getCreditCardById(id: string) {
    return this.prisma.findUnique({
      where: { id },
    })
  }

  async updateCreditCard(
    id: string,
    data: {
      name?: string
      limit?: number
      closingDay?: number
      dueDay?: number
    },
  ) {
    return this.prisma.update({
      where: { id },
      data,
    })
  }

  async deleteCreditCard(id: string) {
    return this.prisma.delete({
      where: { id },
    })
  }
}