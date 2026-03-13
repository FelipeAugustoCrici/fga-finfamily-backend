import { CreditCardsRepository } from './credit-cards.repository'

export class CreditCardsService {
  private repository: CreditCardsRepository = new CreditCardsRepository()

  async createCreditCard(data: {
    name: string
    limit: number
    closingDay: number
    dueDay: number
  }) {
    return this.repository.createCreditCard(data)
  }

  async listCreditCards() {
    return this.repository.getCreditCards()
  }

  async getCreditCardById(id: string) {
    return this.repository.getCreditCardById(id)
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
    return this.repository.updateCreditCard(id, data)
  }

  async deleteCreditCard(id: string) {
    return this.repository.deleteCreditCard(id)
  }
}
