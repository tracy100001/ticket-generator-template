FROM php:8.2-apache

# Enable Apache mod_rewrite if needed
RUN a2enmod rewrite

# Clone the PHP project from GitHub
RUN git clone https://github.com/arikoart/faketicketgenerator.git /var/www/html

# Set working directory
WORKDIR /var/www/html

# Set permissions (optional)
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80
