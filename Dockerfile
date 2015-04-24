FROM debian:7

MAINTAINER	Mackilem Van der Laan <mack.vdl@gmail.com> \
		Danimar Ribeiro <danimaribeiro@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ADD init.sh /etc/init.d/

	##### Instala o Postgresql 9.4 #####

ENV PG_VERSION 9.4
ENV LANG pt_BR.utf8

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    apt-get install -y locales && \
    localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8

RUN apt-get install -y postgresql-$PG_VERSION

	##### Configurando o Postgresql #####

USER postgres
RUN /etc/init.d/postgresql start && psql -c "CREATE USER odoo WITH CREATEDB SUPERUSER PASSWORD 'odoo';"

USER root
VOLUME ["/var/lib/postgresql/data","/etc/postgresql"]
RUN mkdir -p /run/postgres && \
    chown -R postgres /var/lib/postgresql/data && \
    chmod g+s /run/postgresql && \
    chmod g+s /run/postgresql && \
    chown -R postgres:postgres /run/postgresql && \
    chmod +x /etc/init.d/init.sh

	##### Finalização do Container #####

VOLUME /var/lib/postgresql/data
EXPOSE 5432
#CMD /etc/init.d/init.sh
