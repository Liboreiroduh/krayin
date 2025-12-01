FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libc-client2007e-dev \
    libkrb5-dev \
    zip unzip git curl libonig-dev libxml2-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo pdo_mysql mbstring gd xml imap

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY src/ ./
RUN chmod -R 775 storage bootstrap/cache

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN php artisan key:generate

CMD ["php-fpm"]
