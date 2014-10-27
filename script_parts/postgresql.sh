#!/bin/bash

echo "Instalando banco de dados"
apt-get install postgresql --yes

echo "Criando usuario"
su postgres createuser --superuser $USUARIO_BD

echo "Configurando o Postgres"
su postgres psql -c"ALTER user $USUARIO_BD WITH PASSWORD $SENHA_BD"

#mv /opt/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
#mv /opt/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf
