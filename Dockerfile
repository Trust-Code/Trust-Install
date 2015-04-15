FROM ubuntu:14.10

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DB_PASS odoo
RUN apt-get update && apt-get -y upgrade

##### Configura o locale #####
RUN locale-gen pt_BR.UTF-8
RUN update-locale LANG=pt_BR.UTF-8

##### Dependências Odoo APT-GET ######
RUN apt-get install -y --no-install-recommends python-dateutil python-feedparser python-gdata \
	python-ldap python-libxslt1 python-mako python-mock python-openid python-psycopg2 \
	python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
	python-simplejson python-tz python-vatnumber python-vobject python-webdav python-matplotlib \
	python-werkzeug python-xlwt python-yaml python-zsi python-yaml python-cups python-dev \
	libxmlsec1-dev libxml2-dev python-setuptools python-lxml python-decorator python-passlib \
	libxmlsec1-dev libxml2-dev

##### Dependência Odoo PIP #####
RUN apt-get install -y python-pip
RUN pip install unittest2 psutil jinja2 docutils requests pypdf pillow \ 
		https://github.com/aricaldeira/pyxmlsec/archive/master.zip \
		https://github.com/aricaldeira/geraldo/archive/master.zip 

RUN pip install pysped --allow-external PyXMLSec --allow-insecure PyXMLSec

##### Instala wkhtmltopdf #####
ADD http://ufpr.dl.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox.deb
RUN apt-get install -y -f wkhtmltopdf
RUN apt-get install -y xfonts-base xfonts-75dpi && dpkg -i /opt/sources/wkhtmltox.deb

##### Instala o Postgresql 9.4 #####
RUN groupadd -r postgres && useradd -r -g postgres postgres
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN apt-get install -y curl && rm -rf /var/lib/apt/lists/* \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove curl

# >>>>>>>talvez não seja necessário uma vez que o locale já foi ajustado no inicio.<<<<<<<<
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
#--------------------------------

ENV LANG pt_BR.utf8
ENV PG_MAJOR 9.4
ENV PG_VERSION 9.4.1-1.pgdg70+1

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update
RUN apt-get install -y postgresql-common
RUN sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf

RUN apt-get install -y \
		postgresql-$PG_MAJOR=$PG_VERSION \
		postgresql-contrib-$PG_MAJOR=$PG_VERSION \

RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME ["/var/lib/postgresql/data","/etc/postgresql"]

COPY postgresql.sh /opt/

##### Instaça o Nginx #####

user root
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf 

##### Instala o Supervisord #####

RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
COPY /supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN useradd -ms /bin/bash odoo

EXPOSE 80 8069 5432
CMD ["/usr/bin/supervisord"]
