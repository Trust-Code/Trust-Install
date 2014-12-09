#!/bin/bash

set -e

echo ""
echo "Deseja instalar as dependencias? S ou N >>>"
read PERGUNTA

if [ "$PERGUNTA" == "S" ]; then
	echo "Instalando python"
	apt-get install python-pip --yes

	echo ">>> Instalando Bazaar <<<"
	apt-get install bzr --yes

	echo ">>> Instalando python dependencias <<<"
	apt-get install python-dateutil python-feedparser python-gdata python-ldap \
		python-libxslt1 python-mako python-mock python-openid python-psycopg2 \
		python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
		python-simplejson python-tz python-vatnumber python-vobject python-webdav \
		python-werkzeug python-xlwt python-yaml python-zsi python-yaml python-cups python-dev \
		libxmlsec1-dev libxml2-dev python-setuptools python-lxml --yes

	pip install unittest2
	pip install psutil
	pip install jinja2
	pip install docutils
	pip install requests

	echo ">>> Instalando as dependências do Report_Aeroo_ooo <<<"
	apt-get install python-genshi python-openoffice python-lxml python-cairo openoffice.org python-uno --yes
	python $DIR_PADRAO/extras/aeroolib/aeroolib/setup.py install

	cp /arqs/openoffice.sh /etc/init.d/

	chmod u+x /etc/init.d/openoffice.sh
	update-rc.d openoffice.sh defaults

	echo ">>> Instalando PySped, aqui pode dar erro facilmente <<<"
	apt-get install libxmlsec1-dev --yes
	apt-get install libxml2-dev --yes

	if [ $(uname -m) == 'x86_64' ]; then
		pip install https://github.com/aricaldeira/pyxmlsec/archive/master.zip
		echo "skipping"
	else
		pip install pyxmlsec 
	fi

	pip install https://github.com/aricaldeira/geraldo/archive/master.zip
	pip install pysped

	echo "Instalando git"
	apt-get install git --yes

	echo "Instalando bzr"
	apt-get install bzr --yes

fi
