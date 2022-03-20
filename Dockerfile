# Attempt to approximate Dreamhost shared hosting

FROM ubuntu:18.04

# hadolint ignore=DL3003,DL3008
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends apache2 apache2-dev apache2-suexec-custom \
        augeas-tools bash less ca-certificates grc \
        libcgi-simple-perl libfcgi-perl build-essential git libfcgi-dev && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m theuser && \
    mkdir -p /home/theuser/www && chown theuser:theuser /home/theuser/www && \
    a2enmod suexec && \
    a2enmod cgid && \
    git clone https://github.com/FastCGI-Archives/mod_fastcgi.git && \
    cd mod_fastcgi && \
    cp Makefile.AP2 Makefile && \
    make top_dir=/usr/share/apache2 && \
    make top_dir=/usr/share/apache2 install && \
    sed -i -e 's,/var/www,/home/theuser/www,' /etc/apache2/suexec/www-data && \
    sed -i -e 's,LogLevel warn,LogLevel debug,' /etc/apache2/apache2.conf && \
    mkdir -p /var/run/apache2 /var/log/apache2

COPY fastcgi.conf /etc/apache2/conf-enabled/
COPY theuser-site.conf /etc/apache2/sites-enabled/
COPY entry.sh /entry.sh
COPY default_index.html /var/www/html/index.html
ENTRYPOINT ["/entry.sh"]
EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
