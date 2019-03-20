#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    create user "$DB_USERNAME" with password '$DB_PASSWORD';
    alter role "$DB_USERNAME" set client_encoding to 'utf8';
    create database "$DB_NAME" owner "$DB_USERNAME";
EOSQL
