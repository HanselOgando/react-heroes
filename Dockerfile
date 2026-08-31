FROM node:24-alpine3.23 as dev-deps
WORKDIR /app
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
RUN corepack enable
RUN pnpm install

FROM node:24-alpine3.23 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable
RUN pnpm run build

FROM node:24-alpine3.23 as prod-deps
WORKDIR /app
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
RUN corepack enable
RUN pnpm install --prod

FROM nginx:1.23.3 as prod
EXPOSE 80

COPY --from=builder /app/dist /usr/share/nginx/html
CMD [ "nginx", "-g","daemon off;" ]

# WORKDIR /app
# COPY --from=prod-deps /app/node_modules ./node_moddules
# COPY --from=builder /app/dist ./dist
# CMD [ "node", "dist/main.js" ]
