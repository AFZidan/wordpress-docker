# ./Dockerfile
FROM php:8.2-fpm

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev zip unzip git curl \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd

# Install WordPress CLI (optional)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create PHP error log directory
RUN mkdir /var/log/php && \
    touch /var/log/php/php_errors.log && \
    echo "php_admin_value[error_log] = /var/log/php/php_errors.log" >> /usr/local/etc/php-fpm.d/www.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# ✅ Install Node.js and npm (LTS version - Node 18)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Set working directory
WORKDIR /var/www/html

# Copy custom PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/uploads.ini

# Fix FPM listen address for Docker networking
RUN sed -i 's/^listen = .*/listen = 9000/' /usr/local/etc/php-fpm.d/www.conf