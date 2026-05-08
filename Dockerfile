# ============================================
# STAGE 1: Builder
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

RUN apk add --no-cache openssl

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

RUN npx prisma generate

COPY . .

RUN npm run build

# ============================================
# STAGE 2: Production
# ============================================
FROM node:20-alpine AS production

WORKDIR /app

RUN apk add --no-cache openssl

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci --only=production && npm install prisma && npm cache clean --force

COPY prisma ./prisma/

RUN npx prisma generate

COPY --from=builder /app/dist ./dist

CMD ["sh", "-c", "npx prisma migrate deploy || true && node dist/server.js"]
