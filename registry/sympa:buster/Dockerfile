FROM debian:buster
ENV DEBIAN_FRONTEND noninteractive
COPY sympa.preseed /tmp/sympa.preseed
RUN apt -y update
RUN apt -y upgrade
RUN apt -y install inetutils-syslogd sqlite3
RUN debconf-set-selections < /tmp/sympa.preseed
RUN apt -y install --no-install-recommends sympa
