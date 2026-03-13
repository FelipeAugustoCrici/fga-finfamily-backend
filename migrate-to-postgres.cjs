const Database = require('better-sqlite3');
const { Client } = require('pg');

// Configuração do PostgreSQL
const pgClient = new Client({
  host: 'localhost',
  port: 5432,
  database: 'finfamily',
  user: 'postgres',
  password: 'postgres',
});

// Abrir SQLite
const sqlite = new Database('./prisma/dev.db', { readonly: true });

// Função para converter timestamp do SQLite (milliseconds) para ISO 8601
function convertTimestamp(timestamp) {
  if (!timestamp) return null;
  // Se já é uma string ISO, retorna como está
  if (typeof timestamp === 'string' && timestamp.includes('-')) return timestamp;
  // Se é um número (milliseconds), converte para ISO
  return new Date(timestamp).toISOString();
}

async function migrate() {
  try {
    await pgClient.connect();
    console.log('✅ Conectado ao PostgreSQL');

    // Desabilitar constraints temporariamente
    await pgClient.query('SET session_replication_role = replica;');

    // 1. Migrar Families
    console.log('\n📦 Migrando Families...');
    const families = sqlite.prepare('SELECT * FROM Family').all();
    for (const family of families) {
      await pgClient.query(
        'INSERT INTO family (id, name, created_at) VALUES ($1, $2, $3) ON CONFLICT (id) DO NOTHING',
        [family.id, family.name, convertTimestamp(family.createdAt)]
      );
    }
    console.log(`✅ ${families.length} famílias migradas`);

    // 2. Migrar Persons
    console.log('\n👥 Migrando Persons...');
    const persons = sqlite.prepare('SELECT * FROM Person').all();
    for (const person of persons) {
      await pgClient.query(
        `INSERT INTO person (id, name, phone, email, cpf, birth_date, user_id, family_id, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) ON CONFLICT (id) DO NOTHING`,
        [
          person.id,
          person.name,
          person.phone,
          person.email,
          person.cpf,
          convertTimestamp(person.birthDate),
          person.userId,
          person.familyId,
          convertTimestamp(person.createdAt),
        ]
      );
    }
    console.log(`✅ ${persons.length} pessoas migradas`);

    // 3. Migrar Categories
    console.log('\n🏷️  Migrando Categories...');
    const categories = sqlite.prepare('SELECT * FROM Category').all();
    for (const category of categories) {
      await pgClient.query(
        `INSERT INTO category (id, name, type, family_id, created_at) 
         VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO NOTHING`,
        [category.id, category.name, category.type, category.familyId, convertTimestamp(category.createdAt)]
      );
    }
    console.log(`✅ ${categories.length} categorias migradas`);

    // 4. Migrar Expenses
    console.log('\n💸 Migrando Expenses...');
    const expenses = sqlite.prepare('SELECT * FROM Expense').all();
    for (const expense of expenses) {
      await pgClient.query(
        `INSERT INTO expense (id, description, value, category_name, category_id, type, date, month, year, 
         is_credit_card, credit_card_id, person_id, status, recurring_id, created_at, is_deleted, dt_deleted) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17) ON CONFLICT (id) DO NOTHING`,
        [
          expense.id,
          expense.description,
          expense.value,
          expense.categoryName,
          expense.categoryId,
          expense.type,
          convertTimestamp(expense.date),
          expense.month,
          expense.year,
          expense.isCreditCard,
          expense.creditCardId,
          expense.personId,
          expense.status,
          expense.recurringId,
          convertTimestamp(expense.createdAt),
          expense.is_deleted,
          convertTimestamp(expense.dt_deleted),
        ]
      );
    }
    console.log(`✅ ${expenses.length} despesas migradas`);

    // 5. Migrar Salaries
    console.log('\n💰 Migrando Salaries...');
    const salaries = sqlite.prepare('SELECT * FROM Salary').all();
    for (const salary of salaries) {
      await pgClient.query(
        `INSERT INTO salary (id, person_id, value, month, year, created_at, updated_at, is_deleted, dt_deleted) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) ON CONFLICT (id) DO NOTHING`,
        [
          salary.id,
          salary.personId,
          salary.value,
          salary.month,
          salary.year,
          convertTimestamp(salary.createdAt),
          convertTimestamp(salary.updatedAt),
          salary.is_deleted,
          convertTimestamp(salary.dt_deleted),
        ]
      );
    }
    console.log(`✅ ${salaries.length} salários migrados`);

    // 6. Migrar Extra Incomes
    console.log('\n🎁 Migrando Extra Incomes...');
    const extraIncomes = sqlite.prepare('SELECT * FROM ExtraIncome').all();
    for (const income of extraIncomes) {
      await pgClient.query(
        `INSERT INTO extra_income (id, description, value, date, month, year, person_id, created_at, is_deleted, dt_deleted) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) ON CONFLICT (id) DO NOTHING`,
        [
          income.id,
          income.description,
          income.value,
          convertTimestamp(income.date),
          income.month,
          income.year,
          income.personId,
          convertTimestamp(income.createdAt),
          income.is_deleted,
          convertTimestamp(income.dt_deleted),
        ]
      );
    }
    console.log(`✅ ${extraIncomes.length} bônus migrados`);

    // 7. Migrar Budgets
    console.log('\n📊 Migrando Budgets...');
    const budgets = sqlite.prepare('SELECT * FROM Budget').all();
    for (const budget of budgets) {
      await pgClient.query(
        `INSERT INTO budget (id, category_name, category_id, limit_value, month, year, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) ON CONFLICT (id) DO NOTHING`,
        [
          budget.id,
          budget.categoryName,
          budget.categoryId,
          budget.limitValue,
          budget.month,
          budget.year,
          convertTimestamp(budget.createdAt),
        ]
      );
    }
    console.log(`✅ ${budgets.length} orçamentos migrados`);

    // 8. Migrar Goals
    console.log('\n🎯 Migrando Goals...');
    const goals = sqlite.prepare('SELECT * FROM Goal').all();
    for (const goal of goals) {
      await pgClient.query(
        `INSERT INTO goal (id, description, target_value, current_value, deadline, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT (id) DO NOTHING`,
        [goal.id, goal.description, goal.targetValue, goal.currentValue, convertTimestamp(goal.deadline), convertTimestamp(goal.createdAt)]
      );
    }
    console.log(`✅ ${goals.length} metas migradas`);

    // 9. Migrar Credit Cards
    console.log('\n💳 Migrando Credit Cards...');
    const creditCards = sqlite.prepare('SELECT * FROM CreditCard').all();
    for (const card of creditCards) {
      await pgClient.query(
        `INSERT INTO credit_card (id, name, card_limit, closing_day, due_day, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT (id) DO NOTHING`,
        [card.id, card.name, card.limit, card.closingDay, card.dueDay, convertTimestamp(card.createdAt)]
      );
    }
    console.log(`✅ ${creditCards.length} cartões migrados`);

    // 10. Migrar Recurring Expenses
    console.log('\n🔄 Migrando Recurring Expenses...');
    const recurringExpenses = sqlite.prepare('SELECT * FROM RecurringExpense').all();
    for (const recurring of recurringExpenses) {
      await pgClient.query(
        `INSERT INTO recurring_expense (id, description, value, category_name, person_id, start_date, end_date, active, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) ON CONFLICT (id) DO NOTHING`,
        [
          recurring.id,
          recurring.description,
          recurring.value,
          recurring.categoryName,
          recurring.personId,
          convertTimestamp(recurring.startDate),
          convertTimestamp(recurring.endDate),
          recurring.active,
          convertTimestamp(recurring.createdAt),
          convertTimestamp(recurring.updatedAt),
        ]
      );
    }
    console.log(`✅ ${recurringExpenses.length} despesas recorrentes migradas`);

    // 11. Migrar Income Sources
    console.log('\n📥 Migrando Income Sources...');
    const incomeSources = sqlite.prepare('SELECT * FROM IncomeSource').all();
    for (const source of incomeSources) {
      await pgClient.query(
        `INSERT INTO income_source (id, description, value, type, is_recurring, start_date, end_date, active, person_id, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) ON CONFLICT (id) DO NOTHING`,
        [
          source.id,
          source.description,
          source.value,
          source.type,
          source.isRecurring,
          convertTimestamp(source.startDate),
          convertTimestamp(source.endDate),
          source.active,
          source.personId,
          convertTimestamp(source.createdAt),
          convertTimestamp(source.updatedAt),
        ]
      );
    }
    console.log(`✅ ${incomeSources.length} fontes de renda migradas`);

    // 12. Migrar Incomes
    console.log('\n💵 Migrando Incomes...');
    const incomes = sqlite.prepare('SELECT * FROM Income').all();
    for (const income of incomes) {
      await pgClient.query(
        `INSERT INTO income (id, description, value, date, month, year, type, person_id, source_id, created_at, is_deleted, dt_deleted) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) ON CONFLICT (id) DO NOTHING`,
        [
          income.id,
          income.description,
          income.value,
          convertTimestamp(income.date),
          income.month,
          income.year,
          income.type,
          income.personId,
          income.sourceId,
          convertTimestamp(income.createdAt),
          income.is_deleted,
          convertTimestamp(income.dt_deleted),
        ]
      );
    }
    console.log(`✅ ${incomes.length} receitas migradas`);

    // Reabilitar constraints
    await pgClient.query('SET session_replication_role = DEFAULT;');

    console.log('\n🎉 Migração concluída com sucesso!');
  } catch (error) {
    console.error('❌ Erro na migração:', error);
    throw error;
  } finally {
    sqlite.close();
    await pgClient.end();
  }
}

migrate().catch(console.error);
