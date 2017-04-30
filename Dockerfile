#                    ##        .            
#              ## ## ##       ==            
#           ## ## ## ##      ===            
#       /""""""""""""""""\___/ ===        
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
#       \______ o          __/            
#         \    \        __/             
#          \____\______/                
# Dockerfile for ISPConfig 3

FROM debian:7

MAINTAINER m.benyoub@itsolutions.dz


# Let the container know that there is no tty
ENV DEBIAN_FRONTEND="noninteractive"

ARG	FQDN="ispconfig.docker"
ARG	LOCALE="en_US"
ARG	TIMEZONE="UTC"
ARG	MYSQL_ROOT_PWD="password"
ARG	PHPMYADMIN_PWD="password"
ARG	MAILMAN_EMAIL=""
ARG	MAILMAN_PWD="password"
ARG	SSLCERT_ORGANIZATION="My Organization"
ARG	SSLCERT_UNITNAME="Docked Services"
ARG	SSLCERT_EMAIL="root@ispconfig.docker"
ARG	SSLCERT_LOCALITY="New York"
ARG	SSLCERT_STATE="New York"
ARG	SSLCERT_COUNTRY="US"
ARG	SUPERVISOR_LOGIN="root"
ARG	SUPERVISOR_PWD="password"

# --- 0.1 Bash
COPY ./fs/root/.bash_aliases /root/.bash_aliases
RUN echo '. ~/.bash_aliases' >> /root/.bashrc && \
	echo "export TERM=xterm" >> /root/.bashrc

# --- 0.2 Supervisor
ADD ./fs/root/config /root/config
ADD ./fs/usr/local/bin /usr/local/bin
ADD ./fs/etc/supervisor /etc/supervisor
RUN sed -i "s/{{ SUPERVISOR_LOGIN }}/${SUPERVISOR_LOGIN}/g" /etc/supervisor/supervisord.conf
RUN sed -i "s/{{ SUPERVISOR_PWD }}/${SUPERVISOR_PWD}/g" /etc/supervisor/supervisord.conf
ADD ./fs/etc/cron.daily/sql_backup.sh /etc/cron.daily/sql_backup.sh
RUN chmod 755 /usr/local/bin/*
RUN mkdir -p /var/run/sshd /var/log/supervisor /var/run/supervisor
RUN mv /bin/systemctl /bin/systemctloriginal
ADD ./fs/bin/systemctl /bin/systemctl

# --- 0.3 locales
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i ${LOCALE} -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
