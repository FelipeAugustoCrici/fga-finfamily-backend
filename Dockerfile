# ============================================
# STAGE 1: Builder
# ============================================
FROM node:20-alpine AS builder

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências necessárias para o Prisma
RUN apk add --no-cache openssl

# Copia arquivos de dependências
COPY package*.json ./
COPY prisma ./prisma/

# Instala todas as dependências (incluindo devDependencies)
RUN npm ci

# Gera o client do Prisma
RUN npx prisma generate

# Copia o restante do código
COPY . .

# Compila o TypeScript
RUN npm run build

# ============================================
# STAGE 2: Production
# ============================================
FROM node:20-alpine AS production

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências necessárias para o Prisma
RUN apk add --no-cache openssl

# Define variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3333

# Copia arquivos de dependências
COPY package*.json ./

# Instala apenas dependências de produção
RUN npm ci --only=production && npm cache clean --force

# Copia o Prisma schema e migrations
COPY prisma ./prisma/

# Gera o client do Prisma para produção
RUN npx prisma generate

# Copia os arquivos compilados do stage builder
COPY --from=builder /app/dist ./dist

# Expõe a porta da aplicação
EXPOSE 3333

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3333/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

# Comando para iniciar a aplicação
CMD ["node", "dist/server.js"]
