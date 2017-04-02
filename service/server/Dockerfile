FROM debian:jessie
LABEL maintainer francois.menabe@gmail.com

RUN adduser --disabled-login --gecos Sympa sympa

## Install dependencies
RUN apt-get update && apt-get install -y \
    automake \
    build-essential \
    debconf-utils \
    git \
    gettext \
    libarchive-zip-perl \
    libauthcas-perl \
    libcgi-fast-perl \
    libcgi-pm-perl \
    libclass-singleton-perl \
    libclone-perl \
    libcrypt-ciphersaber-perl \
    libcrypt-openssl-x509-perl \
    libcrypt-smime-perl \
    libdata-password-perl \
    libdatetime-format-mail-perl \
    libdatetime-timezone-perl \
    libdbd-csv-perl \
    libdbi-perl \
    libemail-simple-perl \
    libencode-perl \
    libfile-copy-recursive-perl \
    libfile-nfslock-perl \
    libhtml-format-perl \
    libhtml-stripscripts-parser-perl \
    libhtml-tree-perl \
    libintl-perl \
    libio-stringy-perl \
    libmail-dkim-perl \
    libmailtools-perl \
    libmime-charset-perl \
    libmime-encwords-perl \
    libmime-lite-html-perl \
    libmime-tools-perl \
    libmsgcat-perl \
    libnet-cidr-perl \
    libnet-dns-perl \
    libnet-ldap-perl \
    libproc-processtable-perl \
    libregexp-common-perl \
    libscalar-list-utils-perl \
    libsoap-lite-perl \
    libssl-dev \
    libtemplate-perl \
    libterm-progressbar-perl \
    libunicode-linebreak-perl \
    liburi-perl \
    libwww-perl \
    libxml2-dev \
    libxml-libxml-perl \
    libxml-perl \
    mhonarc \
    xml-twig-tools

RUN cpan MHonArc::UTF8
RUN cpan MIME::Charset

## Mysql
RUN echo "mysql-server mysql-server/root_password password a" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password a" | debconf-set-selections
RUN apt-get -y install mysql-server
#RUN echo "CREATE DATABASE sympa CHARACTER SET utf8;" | mysql -u root -pa
#RUN echo "GRANT ALL PRIVILEGES ON sympa.* TO sympa@localhost IDENTIFIED BY 'sympa';" | mysql -u root -pa

## Postfix
RUN mkdir /etc/mail
RUN echo "postfix postfix/mailname string sympa.localhost.org" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get -y install postfix

COPY aliases /etc/aliases
RUN newaliases

RUN sed -e 's@alias_maps\s*=\s*\(.*\)@alias_maps = \1,hash:/etc/mail/sympa_aliases@' -e 's@alias_database\s*=\s*\(.*\)@alias_database = \1,hash:/etc/mail/sympa_aliases@' -i /etc/postfix/main.cf''


## Install Sympa
RUN git clone http://github.com/sympa-community/sympa
WORKDIR sympa
RUN autoreconf; exit 0
RUN automake --add-missing; exit 0
RUN autoreconf
RUN ./configure --enable-fhs --without-initdir --with-unitsdir=/etc/systemd/system --disable-smtpc
RUN make
RUN make install

RUN sed -e "s@my \$db_type;@my \$db_type = 'mysql';@" -e 's@my \$rep = <STDIN>;@#my $rep = <STDIN>;@' -e 's@foreach my \$mod (sort keys %\$cpan_modules) {@foreach my $mod (sort keys %$cpan_modules) {\n        next if ($mod eq "DBD::Oracle" || $mod eq "DBD::Sybase" || $mod eq "DBD::Pg" || $mod eq "DBD::ODBC" || $mod eq "DBD::SQLite");@' -i /home/sympa/sbin/sympa_wizard.pl

RUN /home/sympa/sbin/sympa_wizard.pl --check
RUN /home/sympa/sbin/sympa_wizard.pl --batch email=sympa listmaster=a@localhost.org db_type=mysql db_name=sympa db_host=localhost db_user=sympa db_passwd=sympa


## Nginx
RUN apt-get -y install nginx spawn-fcgi
#COPY sympa-fcgi.service /etc/systemd/system/sympa-fcgi.service
COPY nginx.conf /etc/nginx/sites-available/default

RUN apt-get -y install supervisor
COPY supervisord.conf /etc/supervisord.conf

COPY start.sh /
CMD ["/bin/bash", "/start.sh"]
