FROM enclaive/gramine-os:latest

ARG NGX_VERSION=1.18.0

RUN mkdir /app && cd /app &&\
    apt-get update  &&\
    apt-get install -y build-essential apache2-utils libssl-dev zlib1g zlib1g-dev wget geoip-database libgeoip-dev libprotobuf-c-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    wget https://nginx.org/download/nginx-${NGX_VERSION}.tar.gz &&\
    tar -xzf nginx-${NGX_VERSION}.tar.gz &&\
    cd nginx-${NGX_VERSION} &&\
    ./configure \
    --prefix=/app \
    --without-http_rewrite_module \
    --with-http_geoip_module \
    --with-http_ssl_module &&\
    make -j &&\
    make install &&\
    cd .. &&\
    rm -rf nginx-${NGX_VERSION} nginx-${NGX_VERSION}.tar.gz

COPY app /app/

RUN cd /app && cd /app &&\
    gramine-sgx-gen-private-key \
    && gramine-manifest -Dlog_level=error -Darch_libdir=/lib/x86_64-linux-gnu nginx.manifest.template nginx.manifest \
    && gramine-sgx-sign --manifest nginx.manifest --output nginx.manifest.sgx

ENTRYPOINT [ "/app/entrypoint.sh" ]

EXPOSE 80 443
