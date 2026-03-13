/*
  Warnings:

  - You are about to drop the column `person1` on the `Salary` table. All the data in the column will be lost.
  - You are about to drop the column `person2` on the `Salary` table. All the data in the column will be lost.
  - Added the required column `personId` to the `Expense` table without a default value. This is not possible if the table is not empty.
  - Added the required column `personId` to the `ExtraIncome` table without a default value. This is not possible if the table is not empty.
  - Added the required column `personId` to the `Salary` table without a default value. This is not possible if the table is not empty.
  - Added the required column `value` to the `Salary` table without a default value. This is not possible if the table is not empty.

*/
-- CreateTable
CREATE TABLE "Family" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "Person" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Person_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "Family" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Expense" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "description" TEXT NOT NULL,
    "value" REAL NOT NULL,
    "category" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "date" DATETIME NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "isCreditCard" BOOLEAN NOT NULL DEFAULT false,
    "creditCardId" TEXT,
    "personId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Expense_personId_fkey" FOREIGN KEY ("personId") REFERENCES "Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Expense" ("category", "createdAt", "creditCardId", "date", "description", "id", "isCreditCard", "month", "type", "value", "year") SELECT "category", "createdAt", "creditCardId", "date", "description", "id", "isCreditCard", "month", "type", "value", "year" FROM "Expense";
DROP TABLE "Expense";
ALTER TABLE "new_Expense" RENAME TO "Expense";
CREATE INDEX "Expense_month_year_idx" ON "Expense"("month", "year");
CREATE TABLE "new_ExtraIncome" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "description" TEXT NOT NULL,
    "value" REAL NOT NULL,
    "date" DATETIME NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "personId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ExtraIncome_personId_fkey" FOREIGN KEY ("personId") REFERENCES "Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_ExtraIncome" ("createdAt", "date", "description", "id", "month", "value", "year") SELECT "createdAt", "date", "description", "id", "month", "value", "year" FROM "ExtraIncome";
DROP TABLE "ExtraIncome";
ALTER TABLE "new_ExtraIncome" RENAME TO "ExtraIncome";
CREATE INDEX "ExtraIncome_month_year_idx" ON "ExtraIncome"("month", "year");
CREATE TABLE "new_Salary" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "personId" TEXT NOT NULL,
    "value" REAL NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Salary_personId_fkey" FOREIGN KEY ("personId") REFERENCES "Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Salary" ("createdAt", "id", "month", "updatedAt", "year") SELECT "createdAt", "id", "month", "updatedAt", "year" FROM "Salary";
DROP TABLE "Salary";
ALTER TABLE "new_Salary" RENAME TO "Salary";
CREATE UNIQUE INDEX "Salary_personId_month_year_key" ON "Salary"("personId", "month", "year");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
