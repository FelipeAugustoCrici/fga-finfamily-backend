import { prisma } from '@/lib/prisma'

export class CategoriesRepository {
  async createCategory(data: { name: string; type?: string; familyId?: string }) {
    return prisma.category.create({ data })
  }

  async listCategories(familyId?: string) {
    return prisma.category.findMany({
      where: {
        OR: [{ familyId }, { familyId: null }],
      },
      orderBy: { name: 'asc' },
    })
  }

  async deleteCategory(id: string) {
    return prisma.category.delete({
      where: { id },
    })
  }
}

export const categoriesRepository = new CategoriesRepository()
