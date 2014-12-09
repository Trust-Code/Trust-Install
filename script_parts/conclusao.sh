#!/bin/bash


echo ""
echo "Deseja iniciar o Odoo e configurar o servidor? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

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
	mv .openerp_serverrc server/openerp-server.conf
exit
EOF

cd /

echo ">>> Criando link simbólico do arquivo OPENERP-SERVER <<<"
if [ -f usr/bin/openerp-server ]
then
	echo ">>> O link simbólico OPENERP-SERVER já existe <<<"
else
	ln -s $DIR_PADRAO/server/openerp-server usr/bin/
fi

echo ">>> Criando link simbólico do arquivo OPENERP-SERVER.CONF <<<"
if [ -f etc/openerp/openerp-server.conf ]
then
	echo ">>> O link simbólico OPENERP.CONF já existe <<<"
else
	mkdir /etc/$USUARIO
	ln -s $DIR_PADRAO/server/openerp-server.conf /etc/$USUARIO
fi

echo ">>> Criando arquivo de LOG <<<"
if [ -f var/log/openerp/openerp-server.log ]
then
	echo ">>> O arquivo de log OPENERP-SERVER.LOG já existe <<<"
else
	mkdir var/log/openerp
	touch var/log/openerp/openerp-server.log
	chown -R $USUARIO: var/log/openerp
fi

echo ">>> Criando arquivo de PID <<<"
if [ -f var/run/openerp-server.pid ]
then
	echo ">>> O arquivo de pid OPENERP-SERVER.PID já existe <<<"
else
	touch var/run/openerp-server.pid
	chown $USUARIO: var/run/openerp-server.pid
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



