#!/bin/sh

exec /app/sbin/nginx -g ' error_log stderr info; daemon off;'
