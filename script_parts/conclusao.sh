#!/bin/bash

set -e

USUARIO=$1
export DIR_PADRAO="/home/$USUARIO/odoo"
export DIR_ATUAL=`pwd`

echo ""
echo "Deseja iniciar o Odoo e configurar o servidor? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

if [ ! -d $DIR_PADRAO ];then
	mkdir $DIR_PADRAO -p
fi
if [ ! -d "$DIR_PADRAO/configuracao" ];then
	mkdir "$DIR_PADRAO/configuracao" -p
fi

echo "Copiando arquivos de configuração"
destino="$DIR_PADRAO/configuracao"
atual="$DIR_ATUAL/arqs"

cp "$atual/odoo.conf" "$destino/odoo-$USUARIO.conf"
cp "$atual/nginx" "$destino/nginx-$USUARIO"

echo ">>> Criando link simbólico do arquivo odoo.conf <<<"

link="/etc/init/odoo-$USUARIO.conf"
if [ -f $link ]
then
	echo ">>> O link simbólico odoo.conf já existe <<<"
else
	cp "$destino/odoo-$USUARIO.conf" $link -f
fi

link="/etc/nginx/sites-enabled/nginx-$USUARIO"
if [ -f $link ]
then
	echo ">>> O link simbólico nginx já existe <<<"
else
	ln -s "$destino/nginx-$USUARIO" $link
fi

export CAMINHO="addons,openerp/addons,../odoo-extra"

su  $USUARIO << EOF

echo "Iniciando o openerp para gerar arquivo de configuração"
cd $DIR_PADRAO/odoo
pwd
timeout 3 ./openerp-server --save \
		--db_host=127.0.0.1 \
		--db_port=5432 \
		--db_user=$USUARIO \
		--db_password=$SENHA_BD \
		--addons-path=$CAMINHO

exit 0
EOF

echo "Gerou arquivo de configuração"
mv "/home/$USUARIO/.openerp_serverrc" "$DIR_PADRAO/odoo/odoo-config"

echo "Ajustando as Permissões do Diretorio: $DIR_PADRAO"
chown -R $USUARIO:$USUARIO $DIR_PADRAO
