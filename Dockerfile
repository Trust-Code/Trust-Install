FROM debian:7

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

	##### Instalação do ODOO, Dependências e Configurações Básicas #####

ADD odoo.init /etc/init.d/
ADD conf/odoo.conf /etc/odoo/
ADD http://ufpr.dl.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb /opt/sources/wkhtmltox.deb
ADD apt-requirements /opt/sources/
ADD pip-requirements /opt/sources/

RUN apt-get update && apt-get install -y git python-pip && \
    apt-get install -y $(grep -v '^#' /opt/sources/apt-requirements) && \
    pip install -r /opt/sources/pip-requirements && \
    dpkg -i /opt/sources/wkhtmltox.deb

RUN mkdir /opt/odoo/ && cd /opt/odoo && \
	git clone -b 8.0 --depth=1 https://github.com/odoo/odoo.git ocb && \
    mkdir /var/log/odoo && \
    mkdir /opt/dados && \
    touch /var/log/odoo/odoo.log && \
    touch /var/run/odoo.pid && \
    ln -s /opt/odoo/ocb/openerp-server /usr/bin/odoo-server
    useradd --system --home /opt/odoo --shell /bin/bash --group odoo && \
    chmod u+x /etc/init.d/odoo.init
    chown -R odoo:odoo /opt/odoo && \
    chown -R odoo:odoo /opt/dados && \
    chown -R odoo:odoo /var/log/odoo && \
    chown odoo:odoo /var/run/odoo.pid

	##### Limpeza da Instalação #####

RUN apt-get --purge remove -y git python-pip && \
    apt-get autoremove -y && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/sources/

	##### Finalização do Container #####

VOLUME ["/opt/", "/ect/odoo"]
WORKDIR /opt/
EXPOSE 80 8090
ENTRYPOINT /etc/init.d/odoo.init
CMD ["-c /etc/odoo/odoo.conf"]
