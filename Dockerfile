# Dockerfile cho Next.js Production
FROM node:20-alpine

WORKDIR /app

# Cài đặt dependencies
COPY package*.json ./
RUN npm ci

# Copy code và build
COPY . .
RUN npm run build

# Chạy app
EXPOSE 3000
CMD ["npm", "start"]
