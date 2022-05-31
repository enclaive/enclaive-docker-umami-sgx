#!/bin/sh

set -ex


mkdir -p /app
cd /app

#setup edb, see https://docs.edgeless.systems/edgelessdb/#/getting-started/quickstart-sgx

timeout 60 sh -c 'until nc -z $0 $1; do sleep 1; done' db 8080

rm -f edgelessdb-sgx.json
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
        "drop table if exists event",
        "drop table if exists pageview",
        "drop table if exists session",
        "drop table if exists website",
        "drop table if exists account",
        "create table account ( user_id int unsigned not null auto_increment primary key, username varchar(255) not null, password varchar(60) not null, is_admin bool not null default false, created_at timestamp default current_timestamp, updated_at timestamp default current_timestamp)",
        "create table website ( website_id int unsigned not null auto_increment primary key, website_uuid varchar(36) not null, user_id int unsigned not null, name varchar(100) not null, domain varchar(500), share_id varchar(64) , created_at timestamp default current_timestamp)",
        "create table session ( session_id int unsigned not null auto_increment primary key, session_uuid varchar(36) not null, website_id int unsigned not null references website(website_id) on delete cascade, created_at timestamp default current_timestamp, hostname varchar(100), browser varchar(20), os varchar(20), device varchar(20), screen varchar(11), language varchar(35), country char(2))",
        "create table pageview ( view_id int unsigned not null auto_increment primary key, website_id int unsigned not null, session_id int unsigned not null, created_at timestamp default current_timestamp, url varchar(500) not null, referrer varchar(500))",
        "create table event ( event_id int unsigned not null auto_increment primary key, website_id int unsigned not null, session_id int unsigned not null, created_at timestamp default current_timestamp, url varchar(500) not null, event_type varchar(50) not null, event_value varchar(50) not null)",
        "create index website_user_id_idx on website(user_id)",
        "create index session_created_at_idx on session(created_at)",
        "create index session_website_id_idx on session(website_id)",
        "create index pageview_created_at_idx on pageview(created_at)",
        "create index pageview_website_id_idx on pageview(website_id)",
        "create index pageview_session_id_idx on pageview(session_id)",
        "create index pageview_website_id_created_at_idx on pageview(website_id, created_at)",
        "create index pageview_website_id_session_id_created_at_idx on pageview(website_id, session_id, created_at)",
        "create index event_created_at_idx on event(created_at)",
        "create index event_website_id_idx on event(website_id)",
        "create index event_session_id_idx on event(session_id)",
        "insert into account (username, password, is_admin) values ('admin', '\$2b\$10\$BUli0c.muyCW1ErNJc3jL.vFRFtFJWrT8/GcR4A.sUdCznaXiqFXa', true)"
    ]
}
EOF
curl --cacert edb.pem --data-binary @manifest.json https://db:8080/manifest

cp edb.pem /usr/local/share/ca-certificates/
update-ca-certificates

env

yarn start

