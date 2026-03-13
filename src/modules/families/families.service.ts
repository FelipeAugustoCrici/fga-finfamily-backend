import { FamiliesRepository } from './families.repository'

export class FamiliesService {
  private repository: FamiliesRepository = new FamiliesRepository()

  async createFamily(data: { name: string }) {
    return this.repository.createFamily(data)
  }

  async listFamilies(userId: string) {
    return this.repository.listFamilies(userId)
  }

  async getFamily(id: string, userId: string) {
    return this.repository.getFamily(id, userId)
  }

  async getFamilyByUserId(userId: string) {
    return this.repository.getFamilyByUserId(userId)
  }

  async updateFamily(id: string, data: { name: string }, userId: string) {
    return this.repository.updateFamily(id, data, userId)
  }

  async deleteFamily(id: string, userId: string) {
    return this.repository.deleteFamily(id, userId)
  }
}
