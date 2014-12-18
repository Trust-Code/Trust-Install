#!/bin/bash

USUARIO=$1
export DIR_PADRAO="/home/$USUARIO/odoo"
export DIR_ATUAL=`pwd`

echo ""
echo "Instalar base de dados default? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

echo "Carregar dados de demo ?"
read carregar_demo
if [ $carregar_demo == "S" ]
then
	DEMO=""
else
	DEMO="--without-demo=all"
fi

# echo "Módulos a instalar separados por virgula: "
export modulos="base"

echo "Criando banco de dados: $USUARIO"
su postgres << EOF
	psql -c "CREATE DATABASE $USUARIO WITH ENCODING 'UTF8' OWNER $USUARIO TEMPLATE template0"
	exit 0
EOF

su $USUARIO << EOF

cd $DIR_PADRAO/odoo
pwd
ls

./openerp-server --config=odoo-config --load-language=pt_BR $DEMO --init=$modulos --stop-after-init --database=$USUARIO

exit 0
EOF
