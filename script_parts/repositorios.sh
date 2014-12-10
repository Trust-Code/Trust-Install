#!/bin/bash

echo ""
echo "Deseja efetuar instalação padrão? S ou N"
read PERGUNTA

if [ "$PERGUNTA" != "S" ]; then
	exit 0
fi

echo ""
echo "Qual versão deseja instalar? 7, 8 ou 9"
read VERSAO

case "$VERSAO" in
	7)
		echo "Instalando versão 7"
	;;
	8)
		echo "Instalando versão 8"
	;;	
	9)
		echo "Instalando versão develop 9"
	;;
esac

while read line           
do           
	string=($line) 
	len="${#string[@]}"

	if [ ${#string[@]} -gt 0 ] && [ "${string[0]}" != "Versao" ]; then
		if [ "${string[0]}" == "$VERSAO" ]; then
			if 	[ "${string[3]}" == "git" ]; then
				cmd="git clone ${string[1]} ${string[4]}"
				echo $cmd
				cmd="git checkout ${string[2]}"
				echo $cmd	
			else
				cmd="bzr checkout --lightweight ${string[1]} ${string[4]}"
				$cmd
			fi
		fi
	fi
done < arqs/lista-repositorios

