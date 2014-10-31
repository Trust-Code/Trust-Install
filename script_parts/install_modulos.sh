#!/bin/bash

echo "Digite o nome do novo banco de dados:"

read nome_banco

echo "Carregar dados de demo? (s ou n)"

read carregar_demo

if [ $carregar_demo == "s" ]
then
	DEMO=""
else
	DEMO="--without-demo=all"
fi

# echo "Módulos a instalar separados por virgula: "

# read modulos

#>>> módulos a serem instalados <<<

modulos=l10n_br,l10n_br_account,l10n_br_account_payment,l10n_br_account_payment_extension,l10n_br_account_product,l10n_br_base,l10n_br_crm,l10n_br_crm_zip,l10n_br_data_account,l10n_br_data_account_product,l10n_br_data_base,l10n_br_data_zip,l10n_br_delivery,l10n_br_product,l10n_br_sale,l10n_br_sale_stock,l10n_br_stock,l10n_br_zip,disable_openerp_online,html_signature,l10n_br_data_zip

echo "Criando banco de dados: $nome_banco"

psql -U postgres -h localhost -c "CREATE DATABASE $nome_banco WITH ENCODING 'UTF8' OWNER openerp TEMPLATE template0"

su openerp << EOF

./openerp-server --config=/etc/openerp/openerp-server.conf --load-language=pt_BR $DEMO --init=$modulos --stop-after-init --database=$nome_banco

exit
EOF
