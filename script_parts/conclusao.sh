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

if [ $UBUNTU == true ]; then
	cp "$atual/odoo.conf" "$destino/odoo-$USUARIO.conf" -f
fi
if [ $DEBIAN == true ]; then
	cp "$atual/debian-odoo" "$destino/odoo-$USUARIO.conf" -f
fi
cp "$atual/nginx" "$destino/nginx-$USUARIO" -f

sed -i.bak 's/<usuario>/'$USUARIO'/g' "$destino/odoo-$USUARIO.conf"
sed -i.bak 's/<porta>/80/g' "$destino/nginx-$USUARIO"
sed -i.bak 's/<odoo-porta>/8069/g' "$destino/nginx-$USUARIO"

echo ">>> Criando link simbólico do arquivo odoo.conf <<<"
link="/etc/init/odoo-$USUARIO.conf"
if [ $DEBIAN == true ]; then
	link="/etc/init.d/odoo-$USUARIO"
fi
if [ -f $link ]
then
	echo ">>> O link simbólico odoo.conf já existe <<<"
else
	cp "$destino/odoo-$USUARIO.conf" $link -f
fi
if [ $DEBIAN == true ]; then
	chmod +x $link
	update-rc.d "odoo-$USUARIO" defaults
fi


link="/etc/nginx/sites-enabled/nginx-$USUARIO"
if [ -f $link ]
then
	echo ">>> O link simbólico nginx já existe <<<"
else
	ln -s "$destino/nginx-$USUARIO" $link
fi

export CAMINHO="addons,openerp\/addons"

echo "Atualizando arquivo de configuracao"

echo "Usuario: $USUARIO" 
echo "Usuario: $SENHA_BD" 
echo "Usuario: $CAMINHO" 

cp "$atual/openerp-config" "$DIR_PADRAO/odoo/odoo-config" -f

sed -i.bak 's/<usuario>/'$USUARIO'/g' "$DIR_PADRAO/odoo/odoo-config"
sed -i.bak 's/<odoo-porta>/8069/g' "$DIR_PADRAO/odoo/odoo-config"
sed -i.bak 's/<senha>/'$SENHA_BD'/g' "$DIR_PADRAO/odoo/odoo-config"
sed -i.bak 's/<addons-path>/'$CAMINHO'/g' "$DIR_PADRAO/odoo/odoo-config"


echo "Ajustando as Permissões do Diretorio: $DIR_PADRAO"
chown -R $USUARIO:$USUARIO $DIR_PADRAO
chmod +r "$DIR_PADRAO/odoo/odoo-config"

