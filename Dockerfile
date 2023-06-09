ARG NODE_VERSION=20

ARG NODE_BUILD_IMAGE=node:${NODE_VERSION}-alpine

ARG ENTRYPOINT=index.js

###################################

FROM $NODE_BUILD_IMAGE AS builder

WORKDIR /app/compile

COPY package*.json ./

COPY tsconfig*.json ./

COPY ./src ./src

RUN npm install --quiet

RUN npm run build

###################################

FROM $NODE_BUILD_IMAGE AS installer

WORKDIR /app/dependencies

COPY --from=builder /app/compile/package*.json ./

RUN npm ci --omit=dev

###################################

FROM gcr.io/distroless/nodejs20-debian11 AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=installer /app/dependencies/node_modules ./node_modules

COPY --from=builder /app/compile/dist .

CMD [ "./src/$ENTRYPOINT" ]
