# Build image
FROM node:12.22 AS build
ARG BASE_PATH
ARG DATABASE_TYPE

ENV BASE_PATH=$BASE_PATH
ENV DATABASE_URL="mysql://root:root@db:3306/umami?sslcert=/app/edb.pem"
ENV DATABASE_TYPE="mysql"

WORKDIR /build

RUN yarn config set --home enableTelemetry 0
COPY package.json yarn.lock /build/

# Install only the production dependencies
RUN yarn install --production --frozen-lockfile

# Cache these modules for production
RUN cp -R node_modules/ prod_node_modules/

# Install development dependencies
RUN yarn install --frozen-lockfile

COPY . /build
RUN yarn next telemetry disable
RUN yarn build

# Production image
FROM node:12.22 AS production
WORKDIR /app

# Copy cached dependencies
COPY --from=build /build/prod_node_modules ./node_modules

# Copy generated Prisma client
COPY --from=build /build/node_modules/.prisma/ ./node_modules/.prisma/

COPY --from=build /build/yarn.lock /build/package.json ./
COPY --from=build /build/.next ./.next
COPY --from=build /build/public ./public

RUN apt update && apt install -y netcat

RUN wget https://github.com/edgelesssys/era/releases/latest/download/era -q && chmod +x era && mv era /bin/era
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
EXPOSE 3000
