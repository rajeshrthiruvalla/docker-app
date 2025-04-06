# Stage 1: Composer Dependencies
FROM composer:2.6 AS composer-deps

WORKDIR /app

COPY . .

RUN composer install --no-dev --optimize-autoloader

# Stage 2: PHP-FPM Runtime
FROM php:8.2-fpm-alpine

# Install required system libraries and PHP extensions
RUN apk add --no-cache \
    bash \
    curl \
    git \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    zlib-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
 && docker-php-ext-install \
    intl \
    pdo \
    pdo_mysql \
    mbstring \
    xml \
    zip \
    gd

WORKDIR /var/www/html

COPY --from=composer-deps /app /var/www/html

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html/storage /var/www/html/bootstrap/cache -type d -exec chmod 775 {} \; \
 && find /var/www/html/storage /var/www/html/bootstrap/cache -type f -exec chmod 664 {} \;


EXPOSE 9000

CMD ["php-fpm"]
