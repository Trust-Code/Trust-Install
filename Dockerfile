FROM debian:7

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

	##### Dependências #####

ADD apt-requirements /opt/sources/
ADD pip-requirements /opt/sources/
ADD http://ufpr.dl.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb /opt/sources/wkhtmltox.deb

WORKDIR /opt/sources/
RUN apt-get update && apt-get install -y python-dev && \
    apt-get install -y --no-install-recommends $(grep -v '^#' apt-requirements) && \
    pip install -r pip-requirements && \
    dpkg -i wkhtmltox.deb

	##### Repositórios #####

ADD https://github.com/OCA/OCB/archive/8.0.tar.gz /opt/odoo/

WORKDIR /opt/odoo/
RUN tar -zxvf 8.0.tar.gz && rm 8.0.tar.gz && mv OCB-8.0 OCB

	##### Configurações Odoo #####

ADD conf/odoo.init /etc/init.d/
ADD conf/odoo.conf /etc/odoo/

RUN mkdir /var/log/odoo && \
    mkdir /opt/dados && \
    touch /var/log/odoo/odoo.log && \
    touch /var/run/odoo.pid && \
    ln -s /opt/odoo/OCB/openerp-server /usr/bin/odoo-server && \
    useradd --system --home /opt/odoo --shell /bin/bash odoo && \
    chmod u+x /etc/init.d/odoo.init && \
    chown -R odoo:odoo /opt/odoo && \
    chown -R odoo:odoo /opt/dados && \
    chown -R odoo:odoo /var/log/odoo && \
    chown odoo:odoo /var/run/odoo.pid

	##### Limpeza da Instalação #####

RUN apt-get --purge remove -y python-pip && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/sources/

	##### Finalização do Container #####

VOLUME ["/opt/", "/etc/odoo"]
WORKDIR /opt/
EXPOSE 80 8090
CMD ["su odoo -c '/usr/bin/odoo-server -c /etc/odoo/odoo.conf'"]
