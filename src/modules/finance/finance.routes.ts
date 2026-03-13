import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'

import { budgetsRoutes } from '@/modules/budgets/budgets.routes'
import { categoriesRoutes } from '@/modules/categories/categories.routes'
import { creditCardsRoutes } from '@/modules/credit-cards/credit-cards.routes'
import { expensesRoutes } from '@/modules/expenses/expenses.routes'
import { extrasRoutes } from '@/modules/extras/extras.routes'
import { familiesRoutes } from '@/modules/families/families.routes'
import { goalsRoutes } from '@/modules/goals/goals.routes'
import { incomesRoutes } from '@/modules/incomes/incomes.routes'
import { personsRoutes } from '@/modules/persons/persons.routes'
import { recordsRoutes } from '@/modules/records/records.routes'
import { salariesRoutes } from '@/modules/salaries/salaries.routes'
import { summaryRoutes } from '@/modules/summary/summary.routes'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function financeRoutes(app: FastifyZodInstance) {
  app.register(budgetsRoutes, { prefix: '/budgets' })
  app.register(categoriesRoutes, { prefix: '/categories' })
  app.register(creditCardsRoutes, { prefix: '/credit-cards' })
  app.register(expensesRoutes, { prefix: '/expenses' })
  app.register(extrasRoutes, { prefix: '/extras' })
  app.register(familiesRoutes, { prefix: '/families' })
  app.register(goalsRoutes, { prefix: '/goals' })
  app.register(incomesRoutes, { prefix: '/incomes' })
  app.register(personsRoutes, { prefix: '/persons' })
  app.register(recordsRoutes, { prefix: '/' })
  app.register(salariesRoutes, { prefix: '/salaries' })
  app.register(summaryRoutes, { prefix: '/summary' })
}
