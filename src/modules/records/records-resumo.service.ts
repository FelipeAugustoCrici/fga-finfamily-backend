import { FamiliesService } from '@/modules/families/families.service'
import { RecordsResumoRepository } from './records-resumo.repository'

export class RecordsResumoService {
  private repository = new RecordsResumoRepository()
  private familiesService = new FamiliesService()

  async getResumo(params: {
    mes: number
    ano: number
    familiaId: string
    userId: string
    responsavelId?: string
    categoriaId?: string
    status?: string
  }) {
    const { userId, familiaId, ...rest } = params

    // Valida que o usuário tem acesso à família
    const family = await this.familiesService.getFamily(familiaId, userId)
    if (!family) throw new Error('Acesso negado à família')

    return this.repository.getResumo({ familiaId, ...rest })
  }
}
