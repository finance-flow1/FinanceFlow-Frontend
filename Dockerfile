# ── Stage 1: Build ─────────────────────────────────────────────────────────
# Node layer compiles the React app; never ships to production.
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
ARG BASE_PATH=/
RUN npm run build -- --base=${BASE_PATH}

# ── Stage 2: Production ─────────────────────────────────────────────────────
# Lean nginx image — only the compiled static assets, no Node.js or npm.
FROM nginx:alpine AS runtime

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
