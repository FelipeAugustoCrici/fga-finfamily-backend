-- AlterTable Person: add hasAccess column
ALTER TABLE "Person" ADD COLUMN IF NOT EXISTS "hasAccess" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable Expense: add isShared column
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "isShared" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable Person: add familyId index if missing
CREATE INDEX IF NOT EXISTS "Person_familyId_idx" ON "Person"("familyId");

-- AlterTable Income: add missing indexes
CREATE INDEX IF NOT EXISTS "Income_personId_month_year_idx" ON "Income"("personId", "month", "year");
CREATE INDEX IF NOT EXISTS "Income_personId_is_deleted_idx" ON "Income"("personId", "is_deleted");
CREATE INDEX IF NOT EXISTS "Income_sourceId_idx" ON "Income"("sourceId");

-- AlterTable Salary: add missing index
CREATE INDEX IF NOT EXISTS "Salary_personId_is_deleted_idx" ON "Salary"("personId", "is_deleted");

-- AlterTable ExtraIncome: add missing indexes
CREATE INDEX IF NOT EXISTS "ExtraIncome_personId_month_year_idx" ON "ExtraIncome"("personId", "month", "year");
CREATE INDEX IF NOT EXISTS "ExtraIncome_personId_is_deleted_idx" ON "ExtraIncome"("personId", "is_deleted");

-- AlterTable Expense: add missing indexes
CREATE INDEX IF NOT EXISTS "Expense_personId_month_year_idx" ON "Expense"("personId", "month", "year");
CREATE INDEX IF NOT EXISTS "Expense_personId_is_deleted_idx" ON "Expense"("personId", "is_deleted");
CREATE INDEX IF NOT EXISTS "Expense_categoryId_idx" ON "Expense"("categoryId");
CREATE INDEX IF NOT EXISTS "Expense_status_idx" ON "Expense"("status");
CREATE INDEX IF NOT EXISTS "Expense_is_deleted_month_year_idx" ON "Expense"("is_deleted", "month", "year");
CREATE INDEX IF NOT EXISTS "Expense_creditCardId_idx" ON "Expense"("creditCardId");

-- AlterTable Category: add missing indexes
CREATE INDEX IF NOT EXISTS "Category_familyId_idx" ON "Category"("familyId");
CREATE INDEX IF NOT EXISTS "Category_type_idx" ON "Category"("type");

-- AlterTable IncomeSource: add missing indexes
CREATE INDEX IF NOT EXISTS "IncomeSource_personId_idx" ON "IncomeSource"("personId");
CREATE INDEX IF NOT EXISTS "IncomeSource_personId_active_idx" ON "IncomeSource"("personId", "active");

-- AlterTable RecurringExpense: add missing indexes
CREATE INDEX IF NOT EXISTS "RecurringExpense_personId_idx" ON "RecurringExpense"("personId");
CREATE INDEX IF NOT EXISTS "RecurringExpense_personId_active_idx" ON "RecurringExpense"("personId", "active");

-- AlterTable Goal: add missing indexes
CREATE INDEX IF NOT EXISTS "Goal_familyId_idx" ON "Goal"("familyId");
CREATE INDEX IF NOT EXISTS "Goal_familyId_status_idx" ON "Goal"("familyId", "status");
CREATE INDEX IF NOT EXISTS "Goal_personId_idx" ON "Goal"("personId");

-- AlterTable GoalContribution: add missing indexes
CREATE INDEX IF NOT EXISTS "GoalContribution_goalId_idx" ON "GoalContribution"("goalId");
CREATE INDEX IF NOT EXISTS "GoalContribution_goalId_date_idx" ON "GoalContribution"("goalId", "date");

-- AlterTable Budget: add missing index
CREATE INDEX IF NOT EXISTS "Budget_month_year_idx" ON "Budget"("month", "year");
CREATE INDEX IF NOT EXISTS "Budget_familyId_month_year_idx" ON "Budget"("familyId", "month", "year");

-- AlterTable CreditCard: add missing indexes
CREATE INDEX IF NOT EXISTS "CreditCard_familyId_idx" ON "CreditCard"("familyId");
CREATE INDEX IF NOT EXISTS "CreditCard_familyId_isActive_idx" ON "CreditCard"("familyId", "isActive");
CREATE INDEX IF NOT EXISTS "CreditCard_ownerId_idx" ON "CreditCard"("ownerId");

-- AlterTable CreditCardInvoice: add missing indexes
CREATE INDEX IF NOT EXISTS "CreditCardInvoice_creditCardId_idx" ON "CreditCardInvoice"("creditCardId");
CREATE INDEX IF NOT EXISTS "CreditCardInvoice_creditCardId_referenceMonth_referenceYear_idx" ON "CreditCardInvoice"("creditCardId", "referenceMonth", "referenceYear");
CREATE INDEX IF NOT EXISTS "CreditCardInvoice_status_idx" ON "CreditCardInvoice"("status");
CREATE INDEX IF NOT EXISTS "CreditCardInvoice_dueDate_idx" ON "CreditCardInvoice"("dueDate");

-- AlterTable CreditCardPurchase: add missing indexes
CREATE INDEX IF NOT EXISTS "CreditCardPurchase_creditCardId_idx" ON "CreditCardPurchase"("creditCardId");
CREATE INDEX IF NOT EXISTS "CreditCardPurchase_familyId_idx" ON "CreditCardPurchase"("familyId");
CREATE INDEX IF NOT EXISTS "CreditCardPurchase_ownerId_idx" ON "CreditCardPurchase"("ownerId");
CREATE INDEX IF NOT EXISTS "CreditCardPurchase_purchaseDate_idx" ON "CreditCardPurchase"("purchaseDate");

-- AlterTable CreditCardInstallment: add missing indexes
CREATE INDEX IF NOT EXISTS "CreditCardInstallment_purchaseId_idx" ON "CreditCardInstallment"("purchaseId");
CREATE INDEX IF NOT EXISTS "CreditCardInstallment_invoiceId_idx" ON "CreditCardInstallment"("invoiceId");
CREATE INDEX IF NOT EXISTS "CreditCardInstallment_referenceMonth_referenceYear_idx" ON "CreditCardInstallment"("referenceMonth", "referenceYear");
CREATE INDEX IF NOT EXISTS "CreditCardInstallment_status_idx" ON "CreditCardInstallment"("status");

-- CreateTable CoupleModeConfig
CREATE TABLE IF NOT EXISTS "CoupleModeConfig" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "splitType" TEXT NOT NULL DEFAULT 'equal',
    "participants" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CoupleModeConfig_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "CoupleModeConfig_familyId_key" ON "CoupleModeConfig"("familyId");
CREATE INDEX IF NOT EXISTS "CoupleModeConfig_familyId_idx" ON "CoupleModeConfig"("familyId");

-- CreateTable ExpenseAdjustment
CREATE TABLE IF NOT EXISTS "ExpenseAdjustment" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "fromPersonId" TEXT NOT NULL,
    "toPersonId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "description" TEXT NOT NULL DEFAULT 'Ajuste de contas',
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExpenseAdjustment_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ExpenseAdjustment_familyId_month_year_idx" ON "ExpenseAdjustment"("familyId", "month", "year");

-- CreateTable TelegramLink
CREATE TABLE IF NOT EXISTS "TelegramLink" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "telegramUserId" TEXT NOT NULL,
    "telegramChatId" TEXT NOT NULL,
    "telegramUsername" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TelegramLink_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "TelegramLink_userId_key" ON "TelegramLink"("userId");
CREATE UNIQUE INDEX IF NOT EXISTS "TelegramLink_telegramUserId_key" ON "TelegramLink"("telegramUserId");
CREATE INDEX IF NOT EXISTS "TelegramLink_userId_idx" ON "TelegramLink"("userId");
CREATE INDEX IF NOT EXISTS "TelegramLink_telegramUserId_idx" ON "TelegramLink"("telegramUserId");

-- CreateTable TelegramActivationCode
CREATE TABLE IF NOT EXISTS "TelegramActivationCode" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TelegramActivationCode_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "TelegramActivationCode_userId_key" ON "TelegramActivationCode"("userId");
CREATE UNIQUE INDEX IF NOT EXISTS "TelegramActivationCode_code_key" ON "TelegramActivationCode"("code");
CREATE INDEX IF NOT EXISTS "TelegramActivationCode_code_idx" ON "TelegramActivationCode"("code");

-- CreateTable TelegramPendingAction
CREATE TABLE IF NOT EXISTS "TelegramPendingAction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "telegramChatId" TEXT NOT NULL,
    "actionType" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TelegramPendingAction_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "TelegramPendingAction_userId_status_idx" ON "TelegramPendingAction"("userId", "status");
CREATE INDEX IF NOT EXISTS "TelegramPendingAction_telegramChatId_status_idx" ON "TelegramPendingAction"("telegramChatId", "status");
