#!/bin/bash

set -e

# Verifica se é Ubuntu para colocar pra preencher o sudo.
SESSION=lsb_release -si
if [[ $SESSION -eq 'Ubuntu' ]]; then
	SUDO=sudo
fi

$SUDO apt-get install --yes --force-yes pwgen

# Pergunta a senha para o Postgesql e Usuário Adm do Odoo.
read -p "Digitar uma senha para o BANCO DE DADOS ou deixe em branco para que seja criada uma senha automáticamente (Aconselhável) = " POSTGRES_PASS
if [ -z $POSTGRES_PASS ]; then
        POSTGRES_PASS= pwgen -s 10 1
        echo 'Criado uma senha automática para o banco de dados'
	sleep 3
fi

#TODO fazer essa parte dar um loop para confirmar a senha digitada.
read -p "Digitar uma senha para o USUÁRIO ADMINISTRADOR ou deixe em branco para usar a senha padrão = " ODOO_ADMIN
if [ -z $ODOO_ADMIN ]; then
        ODOO_ADMIN=admin
        echo 'Nenhuma senha foi digitada, sendo assim será utilizado a SENHA PADRÃO = admin'
else
        echo 'Voçe digitou a senha = '$USER_PASS
	sleep 3
fi

# Instalação do Docker
echo ">>Instalando o Docker<<"
if command_exists docker; then
	echo "O docker já está instalado neste servidor, continuando..."
else
	if [[ $SESSION -eq 'Debian' ]]; then
		echo 'deb http://http.debian.net/debian wheezy-backports main' >> /etc/apt/sources.list
		apt-get update
		apt-get install -t wheezy-backports linux-image-amd64
		curl -sSL https://get.docker.com/ | sh

	elif [[ $SESSION -eq 'Ubuntu' ]]; then
		KERNEL=$($SUDO uname -r |cut -c 1-4)  
		if [[ $KERNEL > 3.15 ]]; then  #TODO conferir as versões dos kernel's
			echo ">>Instalando o Docker<<"
			$SUDO apt-get install docker.io

		elif [[ $KERNEL < 3.16 ]]; then
			$SUDO echo deb http://get.docker.io/ubuntu docker main | $SUDO tee /etc/apt/sources.list.d/docker.list
			$SUDO apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
			echo ">>ATUALIZANDO O SISTEMA<<"
			$SUDO apt-get update -qq
			echo ">>INSTALANDO O DOCKER<<"
			$SUDO apt-get install lxc-docker -y
		else
			echo "Versão do seu sistema não é suportado por esta instalação."
			exit
		fi
	fi
fi

echo ">>CONFIGURANDO O USUÁRIO 'trustcode'<<"
$SUDO adduser --system --group --shell=/bin/bash trustcode
$SUDO addgroup trustcode docker

echo ">>BAIXANDO IMAGENS DA TRUSTCODE<<"
docker pull mackilem/trust-odoo

echo ">>AJUSTANDO CONFIGURAÇÕES E INICIANDO OS CONTAINERS<<"
if [[ $DB_PASS != 'odoo' ]]; then
        sed -i 's/db_password = odoo/db_password = '$DB_PASS'/' /etc/odoo/odoo.conf
fi

if [[ $USER_PASS != 'admin' ]]; then
        sed -i 's/admin_passwd = admin/admin_passwd = '$USER_PASS'/' /etc/odoo/odoo.conf
fi

docker run --name pg94 -e POSTGRES_PASSWORD=$POSTGRES_PASS -e POSTGRES_USER=odoo \
	-v /var/log/postgres:/var/log/postgresql \	
	-d postgres:9.4

docker run -p 80:80 -p 8090:8090 --name trust-odoo --link pg94:pg \
	-v  /var/log/odoo:/var/log/odoo \
	-v /var/log/nginx:/var/log/nginx \
	-d mackilem/trust-odoo



