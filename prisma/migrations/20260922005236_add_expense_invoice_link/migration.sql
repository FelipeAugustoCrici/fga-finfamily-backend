-- AlterTable
ALTER TABLE "Expense" ADD COLUMN     "creditCardInvoiceId" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Expense_creditCardInvoiceId_key" ON "Expense"("creditCardInvoiceId");

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_creditCardInvoiceId_fkey" FOREIGN KEY ("creditCardInvoiceId") REFERENCES "CreditCardInvoice"("id") ON DELETE SET NULL ON UPDATE CASCADE;

