#!/bin/sh

cd /app

gramine-sgx-get-token --output nginx.token --sig nginx.sig
gramine-sgx nginx
