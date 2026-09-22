-- AlterTable
ALTER TABLE "Expense" ADD COLUMN     "installmentId" TEXT,
ADD COLUMN     "paymentMethod" TEXT NOT NULL DEFAULT 'account',
ADD COLUMN     "purchaseId" TEXT,
ALTER COLUMN "updatedAt" DROP DEFAULT;

-- CreateIndex
CREATE UNIQUE INDEX "Expense_installmentId_key" ON "Expense"("installmentId");

-- CreateIndex
CREATE INDEX "Expense_purchaseId_idx" ON "Expense"("purchaseId");

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES "CreditCardPurchase"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_installmentId_fkey" FOREIGN KEY ("installmentId") REFERENCES "CreditCardInstallment"("id") ON DELETE SET NULL ON UPDATE CASCADE;

