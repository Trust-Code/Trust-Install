#!/bin/bash

set -e

# Verifica se é Ubuntu para colocar pra preencher o sudo.
if [[ $SESSION -eq 'Ubuntu' ]]; then
	SUDO=sudo
fi

CODENAME=$(lsb_release -sc)

if type pwgen > /dev/null; then
	$SUDO apt-get install --yes --force-yes pwgen
fi

# Pergunta a senha para o Postgesql e Usuário Adm do Odoo.
read -p "Por favor, digite uma senha para o BANCO DE DADOS ou deixe em branco para criar uma senha aleatória = " POSTGRES_PASS
if [ -z $POSTGRES_PASS ]; then
	echo 'CRIANDO SENHA ALEATÓRIA'
        POSTGRES_PASS=$(pwgen -s 10 1)
	sleep 2
fi

#TODO fazer essa parte dar um loop para confirmar a senha digitada.
read -p "Por favor, digite uma senha para o USUÁRIO ADMINISTRADOR ou deixe em branco para usar a senha padrão 'admin' = " ODOO_ADMIN
if [ -z $ODOO_ADMIN ]; then
        ODOO_ADMIN=admin
fi

# Instalação do Docker
echo ">>INSTALANDO O DOCKER<<"
if type docker > /dev/null; then
	echo "O docker já está instalado neste servidor, continuando a instalação do Trust-Odoo..."
	$SUDO service docker restart
else
	if [[ $CODENAME = 'wheezy' ]]; then
		sh -c "echo deb http://ftp.us.debian.org/debian wheezy-backports main > /etc/apt/sources.list.d/wheezy-backports.list"
		apt-get -qq update
		apt-get -t wheezy-backports install linux-image-amd64 -y
	fi
	if [ ! -e /usr/lib/apt/methods/https ]; then
		$SUDO apt-get update
		$SUDO apt-get install -y apt-transport-https
	fi
	$SUDO sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
	$SUDO apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	$SUDO apt-get -qq update
	$SUDO apt-get install -qq -y lxc-docker=1.6.0
fi

echo ">>CONFIGURANDO O USUÁRIO 'trustcode'<<"
$SUDO adduser --system --group --shell=/bin/bash trustcode
$SUDO addgroup trustcode docker

echo ">>BAIXANDO IMAGENS DA TRUSTCODE<<"
$SUDO docker pull postgres:9.4
$SUDO docker pull trustcode/trust_odoo

echo ">>AJUSTANDO CONFIGURAÇÕES E INICIANDO OS CONTAINERS<<"
if  $SUDO docker inspect --format="{{ .Name }}" pg94 2> /dev/null; then
	echo "Já existe um container com nome pg94, o mesmo será removido."
	$SUDO docker rm -f pg94 > /dev/null
fi
if  $SUDO docker inspect --format="{{ .Name }}" trust-odoo 2> /dev/null; then
	echo "Já existe um container com nome trust-odoo, o mesmo será removido."
	$SUDO docker rm -f trust-odoo > /dev/null
fi
echo "Criando Container pg94"
$SUDO docker run --name pg94 -e POSTGRES_PASSWORD=$POSTGRES_PASS -e POSTGRES_USER=odoo \
	-v /var/log/postgres:/var/log/postgresql \
	-d postgres:9.4
echo "Criando Container trust-odoo"
$SUDO docker run -p 80:80 -p 8090:8090 --name trust-odoo --link pg94:pg \
	-v  /var/log/odoo:/var/log/odoo \
	-v /var/log/nginx:/var/log/nginx \
	-d trustcode/trust_odoo

if [[ $POSTGRES_PASS != 'odoo' ]]; then
	echo "Alterando a Senha do Usuário do Banco de Dados..."
        $SUDO docker exec -d trust-odoo sed -i 's/db_password= odoo/db_password = '$POSTGRES_PASS'/' /etc/odoo/odoo.conf
fi
if [[ $ODOO_ADMIN != 'admin' ]]; then
	echo "Alterando a Senha do Usuário Administrador"
        $SUDO docker exec -d trust-odoo sed -i 's/admin_passwd = admin/admin_passwd = '$ODOO_ADMIN'/' /etc/odoo/odoo.conf
fi
echo "CONCLUÍDO"
