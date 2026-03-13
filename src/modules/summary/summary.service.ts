import { FamiliesService } from '@/modules/families/families.service'
import { Family } from '@prisma/client'
import { RecurringExpensesService } from '@/modules/recurring-expenses/recurring-expenses.service'
import { IncomesService } from '@/modules/incomes/incomes.service'
import { SalariesService } from '@/modules/salaries/salaries.service'
import { ExtrasService } from '@/modules/extras/extras.service'
import { ExpensesService } from '@/modules/expenses/expenses.service'
import { BudgetsService } from '@/modules/budgets/budgets.service'
import { BudgetAlert, FinanceReportService } from '@/shared/ai'

export class SummaryService {
  private reportService: FinanceReportService = new FinanceReportService()
  private familiesService: FamiliesService = new FamiliesService()
  private recurringExpensesService: RecurringExpensesService = new RecurringExpensesService()
  private incomesService: IncomesService = new IncomesService()
  private salariesService: SalariesService = new SalariesService()
  private extrasService: ExtrasService = new ExtrasService()
  private expensesService: ExpensesService = new ExpensesService()
  private budgetsService: BudgetsService = new BudgetsService()

  async getSummary(month: number, year: number, userId: string) {
    const families: Array<Family> = await this.familiesService.listFamilies(userId)
    if (families.length === 0) return null
    const familyId: string = families[0].id

    await Promise.all([
      this.recurringExpensesService.processRecurringExpenses(familyId, month, year),
      this.incomesService.processRecurringIncomes(familyId, month, year),
    ])

    const prevMonth = month === 1 ? 12 : month - 1
    const prevYear = month === 1 ? year - 1 : year

    const [
      salaries,
      extras,
      incomes,
      expenses,
      budgets,
      prevSalaries,
      prevExtras,
      prevIncomes,
      prevExpenses,
      family,
    ] = await Promise.all([
      this.salariesService.getSalariesByFamily(familyId, month, year),
      this.extrasService.getExtrasByFamily(familyId, month, year),
      this.incomesService.getIncomesByFamily(familyId, month, year),
      this.expensesService.getExpensesByFamily(familyId, month, year),
      this.budgetsService.listBudgets(month, year),
      this.salariesService.getSalariesByFamily(familyId, prevMonth, prevYear),
      this.extrasService.getExtrasByFamily(familyId, prevMonth, prevYear),
      this.incomesService.getIncomesByFamily(familyId, prevMonth, prevYear),
      this.expensesService.getExpensesByFamily(familyId, prevMonth, prevYear),
      this.familiesService.getFamily(familyId, userId),
    ])

    const totalSalary = salaries.reduce((acc, curr) => acc + curr.value, 0)
    const totalExtras = extras.reduce((acc, curr) => acc + curr.value, 0)
    const totalIncomesFromNewModel = incomes.reduce((acc, curr) => acc + curr.value, 0)

    const totalIncomes = totalSalary + totalExtras + totalIncomesFromNewModel
    const totalExpenses = expenses.reduce((acc, curr) => acc + curr.value, 0)
    const balance = totalIncomes - totalExpenses

    const fixedIncomeTotal =
      incomes.filter((i) => i.type === 'fixed').reduce((acc, curr) => acc + curr.value, 0) +
      totalSalary
    const variableIncomeTotal =
      incomes.filter((i) => i.type !== 'fixed').reduce((acc, curr) => acc + curr.value, 0) +
      totalExtras
    const predictableIncomePercent = totalIncomes > 0 ? (fixedIncomeTotal / totalIncomes) * 100 : 0

    const fixedExpensesTotal = expenses
      .filter((e) => e.type === 'fixed' || e.recurringId)
      .reduce((acc, curr) => acc + curr.value, 0)
    const variableExpensesTotal = totalExpenses - fixedExpensesTotal
    const fixedExpenseCommitment = totalIncomes > 0 ? (fixedExpensesTotal / totalIncomes) * 100 : 0

    const prevTotalSalary = prevSalaries.reduce((acc, curr) => acc + curr.value, 0)
    const prevTotalExtras = prevExtras.reduce((acc, curr) => acc + curr.value, 0)
    const prevTotalIncomesFromNewModel = prevIncomes.reduce((acc, curr) => acc + curr.value, 0)
    const prevTotalExpenses = prevExpenses.reduce((acc, curr) => acc + curr.value, 0)
    const prevTotalIncomes = prevTotalSalary + prevTotalExtras + prevTotalIncomesFromNewModel

    const perPerson = family?.members.map((member) => {
      const memberSalary = salaries.find((s) => s.personId === member.id)?.value || 0
      const memberExtras = extras
        .filter((e) => e.personId === member.id)
        .reduce((acc, curr) => acc + curr.value, 0)
      const memberIncomes = incomes
        .filter((i) => i.personId === member.id)
        .reduce((acc, curr) => acc + curr.value, 0)
      const memberExpenses = expenses
        .filter((e) => e.personId === member.id)
        .reduce((acc, curr) => acc + curr.value, 0)
      const memberIncomeTotal = memberSalary + memberExtras + memberIncomes

      return {
        id: member.id,
        name: member.name,
        income: memberIncomeTotal,
        expenses: memberExpenses,
        contributionPercent: totalIncomes > 0 ? (memberIncomeTotal / totalIncomes) * 100 : 0,
        proportionalExpense:
          totalIncomes > 0 ? (memberIncomeTotal / totalIncomes) * totalExpenses : 0,
      }
    })

    const budgetAlerts: Array<BudgetAlert> = budgets.map((b) => {
      const spent = expenses
        .filter((e) => e.category === b.category)
        .reduce((acc, curr) => acc + curr.value, 0)
      const percent = (spent / b.limitValue) * 100
      return {
        category: b.category,
        limit: b.limitValue,
        spent,
        percent,
        alert: percent > 90,
      }
    })

    let financialHealthScore = 0
    if (totalIncomes > 0) {
      const expenseRatio = totalExpenses / totalIncomes
      if (expenseRatio < 0.5) financialHealthScore = 100
      else if (expenseRatio < 0.7) financialHealthScore = 80
      else if (expenseRatio < 0.9) financialHealthScore = 60
      else if (expenseRatio <= 1) financialHealthScore = 40
      else financialHealthScore = 20
    }

    const averageExpense =
      (totalExpenses + prevTotalExpenses) / (prevTotalIncomes > 0 || totalIncomes > 0 ? 2 : 1)

    const aiReport = this.reportService.generate({
      totalIncomes,
      balance,
      prevBalance: prevTotalIncomes > 0 ? prevTotalIncomes - prevTotalExpenses : undefined,
      budgetAlerts,
    })

    return {
      month,
      year,
      familyId,
      totals: {
        salary: totalSalary,
        extras: totalExtras,
        incomes: totalIncomes,
        expenses: totalExpenses,
        balance,
        fixedExpenses: fixedExpensesTotal,
        variableExpenses: variableExpensesTotal,
        fixedExpenseCommitment,
        fixedIncome: fixedIncomeTotal,
        variableIncome: variableIncomeTotal,
        predictableIncomePercent,
      },
      comparison: {
        incomeChange: totalIncomes - prevTotalIncomes,
        expenseChange: totalExpenses - prevTotalExpenses,
      },
      perPerson,
      healthScore: financialHealthScore,
      forecast: {
        estimatedNextMonthExpenses: averageExpense,
      },
      budgetAlerts,
      aiReport,
      details: {
        salaries,
        extras,
        incomes,
        expenses,
      },
    }
  }
}
