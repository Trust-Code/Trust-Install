#!/bin/bash

echo ">>> Instalando e atualizando o repositório oficial do POSTGRESQL <<<"
cd /
echo "# Repositório Oficial do Postgresql" >> etc/apt/sources.list
echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" >> etc/apt/sources.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update

echo "Instalando banco de dados"
apt-get install postgresql-9.3 --yes

echo "Criando usuario"
su postgres << EOF
	createuser --createdb --username postgres --no-createrole --no-superuser --no-password $USUARIO_BD
#	createuser [-d -U postgres -R -S -w] $USUARIO
	psql -c "ALTER USER $USUARIO_BD WITH PASSWORD '$SENHA_BD'" -d template1
	exit
EOF

#mv /opt/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
#mv /opt/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf

