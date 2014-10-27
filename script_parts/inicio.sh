#!/bin/bash

cd /

if ["$ATUALIZAR" = "sim"] then
	echo "Atualizando o sistema"
	apt-get update
	apt-get upgrade --yes
fi

apt-get install language-pack-pt --yes
locale-gen pt_BR.UTF-8
update-locale LANG=pt_BR.UTF-8

echo "Criando e configurando o usuário"

adduser --system --home $DIR_PADRAO --group --shell /bin/bash $USUARIO


