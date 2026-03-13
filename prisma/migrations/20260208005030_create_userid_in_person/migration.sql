-- AlterTable
ALTER TABLE "Person" ADD COLUMN "userId" TEXT;

-- CreateIndex
CREATE INDEX "Person_userId_idx" ON "Person"("userId");
