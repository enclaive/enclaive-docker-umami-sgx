FROM enclaive/mariadb-sgx:latest

COPY ./umami.sql .

RUN printf "CREATE DATABASE IF NOT EXISTS umami;\nUSE umami;\n" >> init.sql \
    && cat umami.sql >> init.sql \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu mariadb.manifest.template mariadb.manifest \
    && gramine-sgx-sign --key "$SGX_SIGNER_KEY" --manifest mariadb.manifest --output mariadb.manifest.sgx
