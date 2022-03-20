#!/bin/sh

set -e

if [ "$DEBUG" = 'true' ]; then
    set -x
fi

DAEMON=apache2

# shellcheck source=/dev/null
. /etc/apache2/envvars

mkdir -p /home/theuser/logs/www

if [ -d "/app" ]; then
    cp -a /app/* /home/theuser/www/
fi

chown -R theuser:theuser /home/theuser
find /home/theuser/www -type f -exec chmod 644 '{}' ';'
find /home/theuser/www -regextype posix-egrep -type f -regex '.*\.(cgi|pl|fcgi|fcg|fpl)' -exec chmod 755 '{}' ';'

stop() {
    pkill "$DAEMON"
    pkill tail
    echo "Received SIGINT or SIGTERM. Shutting down"
}

echo "Running $*"
if [ "$(basename "$1")" = "$DAEMON" ]; then
    trap stop INT TERM
    tail -F /var/log/apache2/access.log | sed -u 's,.*,\x1B[34mapache access | &\x1B[0m,' &
    tail -F /var/log/apache2/error.log | sed -u 's,.*,\x1B[31mapache error | &\x1B[0m,' &
    tail -F /home/theuser/logs/www/error.log | sed -u 's,.*,\x1B[35muser error | &\x1B[0m,' &
    tail -F /home/theuser/logs/www/access.log | sed -u 's,.*,\x1B[32muser access | &\x1B[0m,' &
    tail -F /var/log/apache2/suexec.log | sed -u 's,.*,\x1B[33msuexec | &\x1B[0m,' &
    "$@"
    stop
else
    exec "$@"
fi
