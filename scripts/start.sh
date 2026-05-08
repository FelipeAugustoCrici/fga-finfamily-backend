#!/bin/sh

echo "Running baseline for existing migrations..."
npx prisma migrate resolve --applied 20260313211914_init 2>/dev/null || true
npx prisma migrate resolve --applied 20260317223730_add_credit_card_module 2>/dev/null || true
npx prisma migrate resolve --applied 20260317225740_add_family_id_to_budget 2>/dev/null || true
npx prisma migrate resolve --applied 20260318010736_add_goal_contributions 2>/dev/null || true
npx prisma migrate resolve --applied 20260508000000_add_missing_columns_and_tables 2>/dev/null || true

echo "Running migrate deploy..."
npx prisma migrate deploy 2>/dev/null || true

echo "Starting server..."
exec node dist/server.js
