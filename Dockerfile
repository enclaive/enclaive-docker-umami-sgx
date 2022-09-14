FROM ubuntu:jammy AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates npm \
    && rm -rf /var/lib/apt/lists/*

ARG NodeVersion=16.17.0
ARG UmamiVersion=1.38.0

ENV DATABASE_TYPE="mysql"

RUN npm install -g n \
    && n "v${NodeVersion}" \
    && hash -r \
    && npm install -g yarn

RUN wget -qO - "https://codeload.github.com/mikecao/umami/tar.gz/refs/tags/v${UmamiVersion}" \
        | tar xzf - && mv "./umami-${UmamiVersion}/" /app/

WORKDIR /app/

RUN yarn config set --home enableTelemetry 0
RUN yarn install --frozen-lockfile
RUN yarn next telemetry disable
RUN yarn build-docker

RUN cp -r ./.next/static/ ./.next/standalone/.next/ \
    && cp -r ./public/ ./.next/standalone/

# final image
FROM enclaive/gramine-os:jammy-33576d39

RUN apt-get update \
    && apt-get install -y --no-install-recommends netcat wget curl patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY --from=builder /usr/local/bin/node /app/
COPY --from=builder /app/.next/standalone/ /app/.next/standalone/

COPY ./umami.manifest.template ./node_modules.diff ./

ARG AdminPassword="umami"
ARG BasePath=""
ARG DatabaseUrl="mysql://root:enclaive@mariadb:3306/umami"

RUN patch -p1 -d ./.next/standalone/ < ./node_modules.diff \
    && gramine-sgx-gen-private-key \
    && gramine-argv-serializer "/app/node" "/app/.next/standalone/server.js" > /app/umami_trusted_argv \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu \
        -Ddatabase_url="${DatabaseUrl}" \
        -Dbase_path="${BasePath}" \
        -Dadmin_password="${AdminPassword}" \
        umami.manifest.template umami.manifest \
    && gramine-sgx-sign --manifest umami.manifest --output umami.manifest.sgx \
    && gramine-sgx-get-token -s umami.sig -o umami.token

EXPOSE 3000/tcp

ENTRYPOINT [ "gramine-sgx", "umami" ]
