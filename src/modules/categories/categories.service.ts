import { CategoriesRepository } from '@/modules/categories/categories.repository'

export class CategoriesService {
  private repository: CategoriesRepository = new CategoriesRepository()

  async createCategory(data: { name: string; type?: string; familyId?: string }) {
    return this.repository.createCategory(data)
  }

  async listCategories(familyId?: string, type?: string, page = 1, limit = 10) {
    return this.repository.listCategories(familyId, type, page, limit)
  }

  async deleteCategory(id: string) {
    return this.repository.deleteCategory(id)
  }
}
