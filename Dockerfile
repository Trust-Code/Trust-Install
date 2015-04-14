FROM ubuntu:14.10

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

RUN apt-get update && apt-get -y upgrade

# Configura o locale
RUN locale-gen pt_BR.UTF-8
RUN update-locale LANG=pt_BR.UTF-8

RUN apt-get install -y --no-install-recommends python-dateutil python-feedparser python-gdata \
	python-ldap python-libxslt1 python-mako python-mock python-openid python-psycopg2 \
	python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
	python-simplejson python-tz python-vatnumber python-vobject python-webdav python-matplotlib \
	python-werkzeug python-xlwt python-yaml python-zsi python-yaml python-cups python-dev \
	libxmlsec1-dev libxml2-dev python-setuptools python-lxml python-decorator python-passlib \
	libxmlsec1-dev libxml2-dev

RUN apt-get install -y git nginx python-pip

RUN pip install unittest2 psutil jinja2 docutils requests pypdf \ 
		https://github.com/aricaldeira/pyxmlsec/archive/master.zip \
		https://github.com/aricaldeira/geraldo/archive/master.zip 

RUN pip install pysped --allow-external PyXMLSec --allow-insecure PyXMLSec

# Instala a dependência para gerar relatórios em .pdf "wkhtmltopdf"
ADD http://ufpr.dl.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox.deb
RUN apt-get install -y -f wkhtmltopdf
RUN apt-get install -y xfonts-base xfonts-75dpi && dpkg -i /opt/sources/wkhtmltox.deb



# Instala o Postgresql 9.4
RUN apt-get install -y postgresql && service postgresql start

#Configurando o Postgresql
USER postgres

RUN /etc/init.d/postgresql start &&\
	createuser --superuser odoo &&\
	psql -c "ALTER user odoo WITH PASSWORD 't9@op15'"

user root

RUN pip install pillow

#Fazer com que o nginx não fique tentando reiniciar
RUN echo "daemon off;" >> /etc/nginx/nginx.conf 

RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
COPY /etc/odoo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/log/postgresql", \
		"/var/lib/postgresql", \	
		"/etc/postgresql",	\	
		"/var/log/nginx", \
		"/var/log/odoo"]

RUN useradd -ms /bin/bash odoo

EXPOSE 80 8069
CMD ["/usr/bin/supervisord"]
