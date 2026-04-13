# Dockerfile đa dụng - supports cả Dev & Prod mode
FROM node:20-alpine

WORKDIR /app

# Install dependencies (support pnpm nếu có)
COPY package.json package-lock.json pnpm-lock.yaml* ./
RUN npm install -g pnpm && \
    (pnpm install || npm install)

# Copy source code
COPY . .

# Chỉ build cho production (tùy theo ENV)
ARG NODE_ENV=production
RUN if [ "$NODE_ENV" = "production" ]; then npm run build; fi

EXPOSE 3000

# Dev mode: npm run dev | Prod mode: npm start
CMD ["sh", "-c", "if [ \"$NODE_ENV\" = \"development\" ]; then npm run dev; else npm start; fi"]
