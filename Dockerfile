FROM node:12.22 AS builder

ARG UmamiVersion=1.32.0

ENV DATABASE_TYPE="mysql"

RUN wget "https://codeload.github.com/mikecao/umami/tar.gz/refs/tags/v${UmamiVersion}" -qO - | tar xzf - && mv "./umami-${UmamiVersion}/" /app/

WORKDIR /app/

RUN yarn config set --home enableTelemetry 0

RUN yarn install --frozen-lockfile

RUN yarn next telemetry disable

RUN yarn build

RUN cp -r ./.next/static/ ./.next/standalone/.next/ \
    && cp -r ./public/ ./.next/standalone/

# final image
FROM enclaive/gramine-os:jammy-33576d39

RUN apt-get update \
    && apt-get install -y nodejs netcat wget curl patch \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/edgelesssys/era/releases/latest/download/era -q && chmod +x era && mv era /bin/era
COPY ./entrypoint.sh /entrypoint.sh

WORKDIR /app/

COPY --from=builder /app/.next/standalone/ /app/.next/standalone/

COPY ./files/ ./

RUN patch -p1 -d ./.next/standalone/ < ./node_modules.diff

ARG AdminPassword="umami"
ARG BasePath=""
ARG DatabaseUrl="mysql://root:root@db:3306/umami?sslcert=/app/edb.pem"

RUN gramine-sgx-gen-private-key \
    && gramine-argv-serializer "/usr/bin/node" "./.next/standalone/server.js" > ./umami_trusted_argv \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu \
        -Ddatabase_url="${DatabaseUrl}" \
        -Dbase_path="${BasePath}" \
        -Dadmin_password="${AdminPassword}" \
        umami.manifest.template umami.manifest \
    && gramine-sgx-sign --manifest umami.manifest --output umami.manifest.sgx \
    && gramine-sgx-get-token -s umami.sig -o umami.token

EXPOSE 3000
ENTRYPOINT /entrypoint.sh
