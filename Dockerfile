# Install debian buster
FROM debian:buster

# Upgrade the systeme
RUN apt update && apt upgrade -y

# Install nginx, mariadb and phpmyadmin
RUN apt install -y nginx mariadb-server php-fpm php-mysql libnss3-tools

# Install mkcert for local ssl
RUN mkdir ./mkcert
COPY /srcs/mkcert ./mkcert/
RUN chmod +x ./mkcert/mkcert && ./mkcert/mkcert -install && ./mkcert/mkcert localhost.com

# Nginx config
COPY /srcs/localhost /etc/nginx/sites-available
COPY srcs/indextest.html /var/www/html
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

# Install phpmyadmin
RUN mkdir /var/www/html/phpmyadmin
COPY srcs/phpMyAdmin-4.9.0.1-english.tar.gz ./
RUN tar xzf phpMyAdmin-4.9.0.1-english.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && rm -rf ./phpMyAdmin-4.9.0.1-english.tar.gz
COPY srcs/config.inc.php /var/www/html/phpmyadmin
RUN chown -R www-data:www-data /var/www/html/phpmyadmin

# Install wordpress
COPY srcs/wordpress.tar.gz ./
RUN tar xzf wordpress.tar.gz --strip-components=1 -C /var/www/html && rm -rf wordpress.tar.gz
COPY srcs/wp-config.php /var/www/html
# Lauch services and start the container
COPY /srcs/sql_init.sh ./
CMD /bin/bash ./sql_init.sh && sleep infinity & wait