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

pwd

echo $REPOSITORIOS
while read line           
do           
    echo $line           
done < arqs/lista-repositorios

