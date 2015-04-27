#!/bin/bash
set -e

POSTGRESQL_BIN=/usr/lib/postgresql/$PG_VERSION/bin/postgres
POSTGRESQL_CONFIG_FILE=/etc/postgresql/$PG_VERSION/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/$PG_VERSION/main

if [ ! -z $PG_PASS ]; then
    su - postgres -c /etc/init.d/postgresql start
    su - postgres psql -c "ALTER USER odoo WITH PASSWORD '$PG_PASS';"
fi

exec su postgres -c '$POSTGRESQL_BIN -D $POSTGRESQL_DATA --config-file=$POSTGRESQL_CONFIG_FILE'
