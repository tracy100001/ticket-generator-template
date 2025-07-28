FROM php:8.2-fpm

# Install required packages (git, unzip, composer optional)
RUN apt-get update && apt-get install -y \
    git unzip curl \
    && docker-php-ext-install pdo pdo_mysql

# Optional: install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clone the GitHub repo
RUN git clone https://github.com/arikoart/faketicketgenerator.git /var/www/html

# Set working directory
WORKDIR /var/www/html

# Optional: install PHP dependencies if needed
# RUN composer install

# Permissions
RUN chown -R www-data:www-data /var/www/html

