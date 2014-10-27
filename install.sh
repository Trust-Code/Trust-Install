#!/bin/bash

export DIR_PADRAO=/home/openerp/v7
export USUARIO=
export USUARIO_BD=''
export SENHA_BD=''

./script_parts/inicio.sh
./script_parts/postgresql.sh
./script_parts/dependencias.sh
./script_parts/repositorios.sh
./script_parts/conclusao.sh
