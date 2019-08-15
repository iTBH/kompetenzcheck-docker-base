FROM php:fpm

# Install php extensions
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-transport-https gnupg zip unzip git libjpeg-dev libpng-dev libfreetype6-dev libmcrypt-dev libxml2-dev wget libxrender1 libfontconfig1 libxext6 libssl1.0 npm \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) pdo_mysql gd opcache \
	&& rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
	&& tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
	&& mv wkhtmltox/bin/wkhtmltopdf /usr/local/bin/ \
	&& chmod +x /usr/local/bin/wkhtmltopdf \
	&& rm wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

# Install composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/composer.phar && chmod +x /usr/local/bin/composer && composer global require hirak/prestissimo

# Install caddy webserver
RUN curl https://getcaddy.com | bash -s personal

ENV NODE_VERSION 6.17.1

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
	&& . /root/.bashrc \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV PATH /root/.nvm/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g webpack cross-env laravel-mix gulp

RUN echo "post_max_size=1G" > /usr/local/etc/php/php.ini \
    && echo "upload_max_filesize=1G" >> /usr/local/etc/php/php.ini \
    && echo "max_file_uploads=100" >> /usr/local/etc/php/php.ini \
    && echo "session.gc_maxlifetime=9999" >> /usr/local/etc/php/php.ini \
    && echo "session.cache-expire=9999" >> /usr/local/etc/php/php.ini \
    && echo "session.cookie-lifetime=9999" >> /usr/local/etc/php/php.ini
