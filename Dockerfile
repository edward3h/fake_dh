# Attempt to approximate Dreamhost shared hosting

FROM ubuntu:18.04

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ssh apache2 apache2-dev apache2-suexec-custom \
        curl mysql-client ack-grep vim augeas-tools bash bash-completion less \
        libcgi-simple-perl libfcgi-perl openjdk-8-jdk build-essential git && \
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
    sed -i -e 's,/var/www,/home/theuser/www,' /etc/apache2/suexec/www-data

COPY fastcgi.conf /etc/apache2/conf-enabled/
COPY theuser-site.conf /etc/apache2/sites-enabled/
COPY entry.sh /entry.sh
COPY default_index.html /var/www/html/index.html
ENTRYPOINT ["/entry.sh"]
EXPOSE 80
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]