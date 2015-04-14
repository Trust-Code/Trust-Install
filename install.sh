#!/bin/bash

set -e

OS=$(uname -r)

if echo $OS | egrep '3.2*' ; then
	echo deb http://get.docker.io/ubuntu docker main | sudo tee /etc/apt/sources.list.d/docker.list
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	echo ">>Atualizando o sistema e instalando o Docker<<"
	apt-get update -qq
	echo ">>Instalando o Docker<<"
	apt-get install lxc-docker -y

elif echo $OS | egrep '3.13*' ; then
	echo ">>Instalando o Docker<<"
        apt-get install docker.io
else
        echo "Versão do sistema não suportado pela instalação."
        exit
fi

echo ">>Configurando Usuário trustcode<<"
adduser --system --group --shell=/bin/bash trustcode
addgroup trustcode docker

echo ">>Baixando o Container<<"
docker pull trustcode/trust-odoo:base

cd /home/trustcode
if [ ! -d data ]; then
	mkdir data
	chown -R trustcode data
fi

echo ">>Baixando arquivos de instalação<<"
apt-get install git -y
cd /home/trustcode
git clone -b base https://Mackilem@bitbucket.org/trustcode/odoo_docker.git

echo ">>Baixando o repositórios odoo<<"
cd /opt
if [ ! -d odoo ]; then
	mkdir odoo
	cd odoo
	git clone -b 8.0 https://github.com/odoo/odoo.git odoo

#INSERIR OS REPOSITÓRIOS FALTANTES

	if [ ! -d dados ]; then
		mkdir dados
	fi
	cd /opt
	chown -R trustcode odoo/
	chmod -R 700 odoo/
else
	echo ">>Já existe uma instalação do Odoo no diretório padrão<<"
fi

cd /
if [ ! -d var/log/odoo ]; then
	mkdir var/log/odoo
	touch var/log/odoo/odoo.log
	chown -R trustcode var/log/odoo
fi
if [ ! -s var/run/odoo.pid ]; then
	touch var/run/odoo.pid
	chown trustcode var/run/odoo.pid
fi
if [ ! -d etc/odoo ]; then
	mkdir etc/odoo
	mv /home/trustcode/odoo_docker/odoo-config /etc/odoo/
	mv /home/trustcode/odoo_docker/supervisord.conf /etc/odoo/
	chown -R trustcode etc/odoo
fi
if [ ! -d var/log/nginx ]; then
	mkdir var/log/nginx
	chown trustcode var/log/nginx
fi

docker run -p 80:80 -p 8090:8090 --name odoo-base \
	-v  /var/log/odoo:/var/log/odoo \
	trustcode/trust-odoo:base

#	-v /var/log/postgres/:/var/log/postgresql \
#	-v /var/log/nginx:/var/log/nginx \


