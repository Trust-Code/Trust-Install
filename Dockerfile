FROM debian:7

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

	##### Instalação do ODOO, Dependências e Configurações Básicas #####

ADD conf/nginx.conf /etc/nginx/nginx.conf 
ADD conf/odoo.conf /etc/odoo/odoo.conf
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD https://pypi.python.org/packages/source/P/Pillow/Pillow-2.8.1.tar.gz /opt/depends/
ADD http://ufpr.dl.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb /opt/sources/wkhtmltox.deb
ADD requirements /opt/sources/

RUN apt-get update && \
    apt-get install -y --no-install-recommends $(grep -v '^#' /opt/sources/requirements) && \
    apt-get install -y git supervisor && \
    dpkg -i /opt/sources/wkhtmltox.deb && \
    tar -vzxf /opt/depends/Pillow-2.8.1.tar.gz && cd /opt/depends/Pillow-2.8.1/ &&  python setup.py install

RUN git clone -b master --depth=1 https://github.com/aricaldeira/pyxmlsec.git /opt/depends/pyxmlsec && \
	cd /opt/depends/pyxmlsec/ && python setup.py install && \
    git clone -b master --depth=1 https://github.com/aricaldeira/geraldo.git /opt/depends/geraldo && \
	cd ../geraldo/ && python setup.py install && \
    git clone -b master --depth=1 https://github.com/aricaldeira/PySPED.git /opt/depends/PySPED && \
	cd ../PySPED/ && python setup.py install && \
    mkdir /opt/odoo/ && cd /opt/odoo && \
	git clone -b 8.0 --depth=1 https://github.com/odoo/odoo.git ocb && \
    mkdir /var/log/odoo && \
    mkdir -p /var/log/supervisor && \
    mkdir /opt/dados && \
    touch /var/log/odoo/odoo.log && \
    touch /var/run/odoo.pid && \
    useradd --system --home /opt/odoo --shell /bin/bash --group odoo && \
    chown -R odoo:odoo /opt/odoo && \
    chown -R odoo:odoo /opt/dados && \
    chown -R odoo:odoo /var/log/odoo && \
    chown odoo:odoo /var/run/odoo.pid

	##### Limpeza da Instalação #####

RUN apt-get --purge remove git wget && \
    apt-get autoremove && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/sources/ && \
    rm /opt/depends/Pillow-2.8.1.tar.gz

	##### Finalização do Container #####

VOLUME  /opt/ \
	/etc/odoo/ \
	/etc/ngix/ \
	/etc/supervisor

EXPOSE 80 8090
CMD ["/usr/bin/supervisord"]
