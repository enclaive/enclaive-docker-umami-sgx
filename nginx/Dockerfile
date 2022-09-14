FROM enclaive/nginx-sgx:latest

COPY ./nginx.conf /entrypoint/conf/

RUN gramine-sgx-gen-private-key "$SGX_SIGNER_KEY" \
    && /manifest/manifest.sh nginx
