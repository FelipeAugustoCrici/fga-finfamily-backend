import { SalariesRepository } from '@/modules/salaries/salaries.repository'

export class SalariesService {
  private repository: SalariesRepository = new SalariesRepository()

  async listSalaries(personId: string, month: number, year: number) {
    return this.repository.getSalary(personId, month, year)
  }

  async saveSalary(data: { personId: string; value: number; month: number; year: number }) {
    return this.repository.upsertSalary(data)
  }

  async updateSalary(
    id: string,
    data: Partial<{ value: number; month: number; year: number; personId: string }>,
  ) {
    return this.repository.updateSalary(id, data)
  }

  async getSalariesByFamily(familyId: string, month: number, year: number) {
    return this.repository.getSalariesByFamily(familyId, month, year)
  }

  async deleteSalary(id: string) {
    return this.repository.deleteSalary(id)
  }
}
