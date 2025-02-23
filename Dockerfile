FROM docker.io/library/node:22.14.0-alpine3.21 as build

RUN apk add --no-cache python3 make build-base

WORKDIR app
COPY . .
RUN corepack enable && yarn install && yarn run build

FROM docker.io/library/node:22.14.0-alpine3.21

WORKDIR app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json .
RUN corepack enable
ENTRYPOINT ["yarn", "run", "start"]
