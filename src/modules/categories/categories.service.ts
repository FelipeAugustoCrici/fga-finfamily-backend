import { CategoriesRepository } from '@/modules/categories/categories.repository'

export class CategoriesService {
  private repository: CategoriesRepository = new CategoriesRepository()

  async createCategory(data: { name: string; type?: string; familyId?: string }) {
    return this.repository.createCategory(data)
  }

  async listCategories(familyId?: string) {
    return this.repository.listCategories(familyId)
  }

  async deleteCategory(id: string) {
    return this.repository.deleteCategory(id)
  }
}
