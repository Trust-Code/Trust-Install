#!/bin/bash

set -e

echo ""
echo "Deseja instalar o postgres? S ou N >>>"
read PERGUNTA

if [ "$PERGUNTA" == "S" ];
then
	echo "Instalando banco de dados"
	apt-get install postgresql-9.3 --yes
fi

echo "Criando usuario no banco de dados: $1"
su postgres <<EOF
	createuser --createdb --username postgres --no-createrole --no-superuser --no-password $1
	psql -c "ALTER USER $1 WITH PASSWORD '$SENHA_BD'" -d template1
	exit
EOF

#mv /opt/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
#mv /opt/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf

