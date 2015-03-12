#!/bin/bash

set -e

if test $# -gt 0; then

	export ATUALIZAR='N'
	export SENHA_BD=`date | md5sum`
	os_version=`uname -v`
	if [[ $os_version == *"Ubuntu"* ]]; then
		export UBUNTU=true
		export DEBIAN=false
	fi
	if [[ $os_version == *"Debian"* ]]; then
		export UBUNTU=false
		export DEBIAN=true
	fi

	SENHA_BD=${SENHA_BD:0:10}

	./script_parts/inicio.sh $1
	./script_parts/postgresql.sh $1
	./script_parts/dependencias.sh $1
	./script_parts/repositorios.sh $1
	./script_parts/conclusao.sh $1
	./script_parts/install_modulos.sh $1

else
	echo "<<< Invalid parameters >>>"
	echo "Usage: sudo ./install.sh USER_NAME"
fi
