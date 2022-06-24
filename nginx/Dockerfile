FROM enclaive/nginx-sgx:latest

COPY ./nginx.conf /entrypoint/conf/
COPY ./nginx.manifest.template /manifest/
COPY ./nginx.sh /nginx.sh

RUN gramine-sgx-gen-private-key "$SGX_SIGNER_KEY" \
    && /manifest/manifest.sh nginx

ENTRYPOINT [ "/nginx.sh" ]
