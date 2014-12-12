#!/bin/bash

set -e

USUARIO=$1
DIR_PADRAO="/home/$USUARIO/odoo"
DIR_ATUAL=`pwd`

echo ""
echo "Deseja iniciar o Odoo e configurar o servidor? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

if [ ! -d $DIR_PADRAO ];then
	mkdir $DIR_PADRAO -p
fi

echo ">>> Criando link simbólico do arquivo odoo.conf <<<"
arquivo="$DIR_PADRAO/odoo/odoo.conf"
cp arqs/openerp-config $arquivo

destino="/etc/init/odoo-$USUARIO.conf"
if [ -f $arquivo ]
then
	echo ">>> O link simbólico odoo.conf já existe <<<"
else
	ln -s $arquivo $destino
fi


echo ">>> Criando link simbólico do arquivo nginx-opnerp.conf <<<"
arquivo="$DIR_PADRAO/odoo/openerp-config"
cp arqs/openerp-config $arquivo

destino="/etc/init/odoo-$USUARIO.conf"
if [ -f $arquivo ]
then
	echo ">>> O link simbólico odoo.conf já existe <<<"
else
	ln -s $arquivo $destino
fi



echo "Criando o arquivo de configuração"
export CAMINHO="/addons,../web/addons,../account_payment,../account_payment_extension,../fiscal_rules,../core_br,../nfe"

su  $USUARIO << EOF
echo "Iniciando o openerp para gerar arquivo de configuração"

timeout --kill=3 3 ./openerp-server --save \
		--db_host=127.0.0.1 \
		--db_port=5432 \
		--db_user=$USUARIO \
		--db_password=$SENHA_BD \
		--addons-path=$CAMINHO
EOF


echo "Ajustando as Permissões do Diretorio: $DIR_PADRAO"
chown -R $USUARIO:$USUARIO $DIR_PADRAO








