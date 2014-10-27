#!/bin/bash

cd /

echo "Iniciando a atualização da lista de pacotes"
apt-get update

echo "Iniciando a atualização"
apt-get upgrade --yes

apt-get install language-pack-pt --yes
locale-gen pt_BR.UTF-8
update-locale LANG=pt_BR.UTF-8


