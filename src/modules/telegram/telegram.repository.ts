import { prisma } from '@/lib/prisma'

export class TelegramRepository {
  async findLinkByUserId(userId: string) {
    return prisma.telegramLink.findUnique({ where: { userId } })
  }

  async findLinkByTelegramUserId(telegramUserId: string) {
    return prisma.telegramLink.findUnique({ where: { telegramUserId } })
  }

  async createLink(data: {
    userId: string
    telegramUserId: string
    telegramChatId: string
    telegramUsername?: string
  }) {
    return prisma.telegramLink.create({ data })
  }

  async deleteLink(userId: string) {
    return prisma.telegramLink.delete({ where: { userId } })
  }

  async findActivationCode(userId: string) {
    return prisma.telegramActivationCode.findUnique({ where: { userId } })
  }

  async upsertActivationCode(userId: string, code: string, expiresAt: Date) {
    return prisma.telegramActivationCode.upsert({
      where: { userId },
      create: { userId, code, expiresAt },
      update: { code, expiresAt },
    })
  }

  async findActivationCodeByCode(code: string) {
    return prisma.telegramActivationCode.findUnique({ where: { code } })
  }

  async deleteActivationCode(userId: string) {
    return prisma.telegramActivationCode.delete({ where: { userId } })
  }

  async createPendingAction(data: {
    userId: string
    telegramChatId: string
    actionType: string
    payload: object
  }) {
    return prisma.telegramPendingAction.create({ data })
  }

  async findPendingAction(telegramChatId: string) {
    return prisma.telegramPendingAction.findFirst({
      where: { telegramChatId, status: 'pending' },
      orderBy: { createdAt: 'desc' },
    })
  }

  async resolvePendingAction(id: string, status: 'confirmed' | 'cancelled') {
    return prisma.telegramPendingAction.update({ where: { id }, data: { status } })
  }
}
