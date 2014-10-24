#!/bin/bash

echo "Instalando banco de dados"
apt-get install postgresql --yes

echo "Criando usuario"
su -u postgres createuser --superuser openerp

echo "Configurando o Postgres"
su -u postgres psql -c"ALTER user openerp WITH PASSWORD '1234'"

#mv /opt/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
#mv /opt/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf
