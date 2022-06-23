#!/bin/sh

set -ex

mkdir -p /app
cd /app

#setup edb, see https://docs.edgeless.systems/edgelessdb/#/getting-started/quickstart-sgx
timeout 60 sh -c 'until nc -z $0 $1; do sleep 1; done' db 8080

wget https://github.com/edgelesssys/edgelessdb/releases/latest/download/edgelessdb-sgx.json
/bin/era -c edgelessdb-sgx.json -h db:8080 -output-root /app/edb.pem -skip-quote

cat - > manifest.json <<EOF
{
    "sql": [
        "CREATE USER root@localhost IDENTIFIED BY 'root'",
        "CREATE USER root@'%' IDENTIFIED BY 'root'",
        "GRANT ALL ON *.* TO root WITH GRANT OPTION",
        "CREATE DATABASE umami",
        "USE umami",
        $(perl -0pe 's|\n||g;s|([^;]*);|"\1",\n|g' schema.mysql.sql | head -c-2)
    ]
}
EOF
curl --cacert edb.pem --data-binary @manifest.json https://db:8080/manifest

cp edb.pem /usr/local/share/ca-certificates/
update-ca-certificates

gramine-sgx umami
