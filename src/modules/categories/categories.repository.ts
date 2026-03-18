import { prisma } from '@/lib/prisma'

export class CategoriesRepository {
  async createCategory(data: { name: string; type?: string; familyId?: string }) {
    return prisma.category.create({ data })
  }

  async listCategories(familyId?: string, type?: string, page = 1, limit = 10) {
    const where = {
      AND: [
        { OR: [{ familyId }, { familyId: null }] },
        ...(type ? [{ type }] : []),
      ],
    }
    const [data, total] = await Promise.all([
      prisma.category.findMany({
        where,
        orderBy: { name: 'asc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.category.count({ where }),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async deleteCategory(id: string) {
    return prisma.category.delete({
      where: { id },
    })
  }
}

export const categoriesRepository = new CategoriesRepository()
