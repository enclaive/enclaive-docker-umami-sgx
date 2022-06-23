FROM enclaive/nginx-sgx:latest

RUN gramine-sgx-gen-private-key /gramine-os/sgx-signer-key/enclaive-key.pem

COPY ./nginx.conf /entrypoint/conf/
COPY ./nginx.manifest.template /manifest/

WORKDIR /manifest/

RUN /manifest/manifest.sh nginx

COPY ./nginx.sh /

ENTRYPOINT [ "/nginx.sh" ]