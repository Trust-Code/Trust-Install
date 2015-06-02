FROM debian:7

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

	##### Dependências #####

# Configura o locale
RUN locale-gen pt_BR.UTF-8
RUN update-locale LANG=pt_BR.UTF-8

ADD apt-requirements /opt/sources/
ADD pip-requirements /opt/sources/
ADD http://sourceforge.net/projects/wkhtmltopdf/files/archive/0.12.1/wkhtmltox-0.12.1_linux-wheezy-amd64.deb/download /opt/sources/wkhtmltox.deb

WORKDIR /opt/sources/
RUN apt-get update && apt-get install -y python-dev nginx supervisor git
RUN apt-get install -y --no-install-recommends $(grep -v '^#' apt-requirements)

RUN pip install -r pip-requirements && \
    dpkg -i wkhtmltox.deb

	##### Repositórios #####

WORKDIR /opt/odoo/
RUN git clone --depth=1 http://github.com/OCA/OCB.git OCB
RUN git clone --depth=1 http://github.com/Trust-Code/odoo-brazil-eletronic-documents.git eletronic-docs
RUN git clone --depth=1 http://github.com/Trust-Code/l10n-brazil.git l10n-brasil
RUN git clone --depth=1 http://github.com/Trust-Code/account-fiscal-rule.git fiscal-rule
RUN git clone --depth=1 http://github.com/Trust-Code/trust-addons.git trust-addons
RUN git clone --depth=1 http://github.com/Trust-Code/server-tools.git server-tools
WORKDIR /opt

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/
ADD conf/nginx.conf /etc/nginx/
ADD conf/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /var/log/odoo && \
    mkdir /opt/dados && \
    touch /var/log/odoo/odoo.log && \
    touch /var/run/odoo.pid && \
    ln -s /opt/odoo/OCB/openerp-server /usr/bin/odoo-server && \
    useradd --system --home /opt --shell /bin/bash odoo && \
    chown -R odoo:odoo /opt/odoo && \
    chown -R odoo:odoo /etc/odoo/odoo.conf && \
    chown -R odoo:odoo /opt/dados && \
    chown -R odoo:odoo /var/log/odoo && \
    chown odoo:odoo /var/run/odoo.pid

	##### Limpeza da Instalação #####

RUN apt-get --purge remove -y python-pip git && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/sources/

	##### Finalização do Container #####

VOLUME ["/opt/", "/etc/odoo"]
EXPOSE 80 8090
CMD ["/usr/bin/supervisord"]
