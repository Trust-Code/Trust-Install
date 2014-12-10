#!/bin/bash

USUARIO=$1
DIR_PADRAO="/home/$USUARIO/odoo"
DIR_ATUAL=pwd

echo ""
echo "Deseja efetuar instalação padrão? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

echo ""
echo "Qual versão deseja instalar? 7, 8 ou 9"
read VERSAO

echo "Instalando versão $VERSAO"

cd $DIR_PADRAO
pwd
while read line           
do           
	string=($line) 
	len="${#string[@]}"

	if [ ${#string[@]} -gt 0 ] && [ "${string[0]}" != "Versao" ]; then #Se a linha não for vazia e não for a primeira
		if [ "${string[0]}" == "$VERSAO" ]; then  #Filtra a versão
			if 	[ "${string[3]}" == "git" ]; then  #Se for o git
				cmd="git clone ${string[1]} ${string[4]}"				
				$cmd
				cd ${string[4]}
				cmd="git checkout ${string[2]}"
				$cmd
				cd .. 	
				cd ..
			else #Se for o bazaar
				cmd="bzr checkout --lightweight ${string[1]} ${string[4]}"
				$cmd
			fi
		fi
	fi
done < arqs/lista-repositorios

cd $DIR_ATUAL


