#!/bin/bash


echo ""
echo "Deseja iniciar o Odoo e configurar o servidor? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi
USUARIO=$1
DIR_PADRAO="/home/$USUARIO/odoo"

echo "Ajustando as Permissões do Diretorio: $DIR_PADRAO"

if [ ! -d $DIR_PADRAO ];then
	mkdir $DIR_PADRAO
fi
mv tmp/* $DIR_PADRAO
chown -R $USUARIO:$USUARIO $DIR_PADRAO
rm tmp -R

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

su  $USUARIO << EOF
	echo "Movendo arquivos de configuracao"

	cd ~
	mv .openerp_serverrc server/openerp-server.conf
exit
EOF


echo ">>> Criando link simbólico do arquivo OPENERP-SERVER.CONF <<<"
if [ -f etc/openerp/openerp-server.conf ]
then
	echo ">>> O link simbólico OPENERP.CONF já existe <<<"
else
	mkdir /etc/$USUARIO
	ln -s $DIR_PADRAO/server/openerp-server.conf /etc/$USUARIO
fi

echo ">>> Criando o serviço OPENERP-SERVER <<<"
if [ -f etc/init.d/openerp-server ]
then
	echo ">>> O ETC/INIT.D/OPENERP-SERVER de serviço já existe <<<"
else
	ln -s $DIR_PADRAO/server/debian/openerp.init etc/init.d/openerp-server
	chmod u+x /etc/init.d/openerp-server
	update-rc.d openerp-server defaults
fi



