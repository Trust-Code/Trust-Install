#!/bin/bash

echo "ajustando as Permissões do Diretorio"

chown -R $USUARIO: $DIR_PADRAO

echo "Criando o arquivo de configuração"
cd $DIR_PADRAO/server

CAMINHO="$DIR_PADRAO/addons,../web/addons,../account_payment,../account_payment_extension,../fiscal_rules,../core_br,../nfe"

#,../data_br

su  $USUARIO << EOF

echo "Iniciando o openerp para gerar arquivo de configuração"

timeout --kill=3 3 ./openerp-server --save \
		--db_host=127.0.0.1 \
		--db_port=5432 \
		--db_user=$USUARIO_BD \
		--db_password=$SENHA_BD \
		--addons-path=$CAMINHO
EOF

su  $USUARIO << EOF
	echo "Movendo arquivos de configuracao"

	cd ~
	mv .openerp_serverrc server/openerp.conf

	mv server/debian/openerp.conf server/
exit
EOF

cd /

if [ -f etc/openerp/openerp.conf ]
then
	echo ">>> O link simbólico OPENERP.CONF já existe <<<"
else
	mkdir /etc/$USUARIO
	ln -s $DIR_PADRAO/server/openerp.conf /etc/$USUARIO
fi
