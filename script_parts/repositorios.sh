#!/bin/bash

set -e 

USUARIO=$1
DIR_PADRAO="/home/$USUARIO/odoo"
DIR_ATUAL=`pwd`

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

if [ ! -d $DIR_PADRAO ];then
	mkdir $DIR_PADRAO -p
fi

cd $DIR_PADRAO
arquivo="$DIR_ATUAL/arqs/lista-repositorios"

while read line           
do           
	string=($line) 

	if [ ${#string[@]} -gt 0 ] && [ "${string[0]}" != "Versao" ]; then #Se a linha não for vazia e não for a primeira
		if [ "${string[0]}" == "$VERSAO" ]; then  #Filtra a versão
			echo ""
			echo $line
			echo ""
			if 	[ "${string[3]}" == "git" ]; then  #Se for o git

				if [ ! -d ${string[4]} ];then #O diretório não existe
					cmd="git clone ${string[1]} ${string[4]}"				
					$cmd
				fi
				
				cd ${string[4]}
				cmd="git checkout ${string[2]}"
				$cmd
				cmd="git pull"
				$cmd
				cd .. 	

			else #Se for o bazaar
				
				if [ ! -d ${string[4]} ];then #O diretório não existe
					cmd="bzr checkout --lightweight ${string[1]} ${string[4]}"
					$cmd
				fi
				cd ${string[4]}
				cmd="bzr update"
				$cmd
				cd .. 
			fi
		fi
	fi
done < $arquivo

cd $DIR_ATUAL


