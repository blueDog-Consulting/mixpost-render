# Start with a base image that has PHP and Composer installed
FROM php:8.1-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    libonig-dev \
    libmagickwand-dev \
    && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql pdo_pgsql opcache

# Install and enable Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install ImageMagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Copy the application source code
COPY . .

# Set permissions
RUN chmod -R 755 /var/www/html/storage

# Expose port 9000 for php-fpm
EXPOSE 9000

# Set environment variables from Render
ENV APP_NAME=${APP_NAME} \
    APP_DEBUG=${APP_DEBUG} \
    APP_KEY=${APP_KEY} \
    DB_DATABASE=${DB_DATABASE} \
    DB_USERNAME=${DB_USERNAME} \
    DB_PASSWORD=${DB_PASSWORD}

# Start php-fpm server
CMD ["php-fpm"]
