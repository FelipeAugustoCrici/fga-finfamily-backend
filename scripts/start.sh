#!/bin/sh
set -e

echo "Checking migration status..."

# Tenta rodar migrate deploy normalmente
if npx prisma migrate deploy 2>&1; then
  echo "Migrations applied successfully"
else
  EXIT_CODE=$?
  ERROR=$(npx prisma migrate deploy 2>&1 || true)
  
  # Se o erro for P3005 (schema não vazio sem histórico), faz baseline
  if echo "$ERROR" | grep -q "P3005"; then
    echo "Database has existing schema without migration history. Running baseline..."
    
    npx prisma migrate resolve --applied 20260313211914_init || true
    npx prisma migrate resolve --applied 20260317223730_add_credit_card_module || true
    npx prisma migrate resolve --applied 20260317225740_add_family_id_to_budget || true
    npx prisma migrate resolve --applied 20260318010736_add_goal_contributions || true
    npx prisma migrate resolve --applied 20260508000000_add_missing_columns_and_tables || true
    
    echo "Baseline complete. Running migrate deploy..."
    npx prisma migrate deploy || true
  else
    echo "Migration error (non-P3005), continuing anyway..."
  fi
fi

echo "Starting server..."
exec node dist/server.js
