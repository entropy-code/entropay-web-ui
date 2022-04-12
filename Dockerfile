FROM node:17.1.0-alpine3.12 AS dependencies
ENV NODE_ENV=production
WORKDIR /app
COPY package.json ./
RUN yarn install

FROM node:17.1.0-alpine3.12 AS builder
ENV NODE_ENV=production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN yarn build

FROM node:17.1.0-alpine3.12 AS runner
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production
COPY --from=builder /app/dist/apps/app/public ./public
COPY --from=builder /app/dist/apps/app/.next ./.next
COPY --from=builder /app/dist/apps/app/package.json ./
COPY --from=dependencies /app/node_modules ./node_modules
USER node
EXPOSE 3000
CMD [ "yarn", "start" ]