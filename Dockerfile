FROM php:8.2-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip nginx \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

COPY nginx-laravel.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Use supervisord to manage both nginx and php-fpm properly
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
