#!/bin/bash

apt update -y
apt install -y nginx git unzip supervisor

apt install -y php8.2 php8.2-fpm php8.2-xml php8.2-curl php8.2-mbstring php8.2-mysql php8.2-zip php8.2-gd php8.2-bcmath

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

if [ ! -d "/var/www/krayin" ]; then
    mkdir -p /var/www/krayin
fi

cd /var/www/krayin

git clone https://github.com/Liboreiroduh/krayin . || true

composer install --no-interaction --prefer-dist

cp .env.example .env
php artisan key:generate
php artisan storage:link
php artisan migrate --force

chown -R www-data:www-data /var/www/krayin
chmod -R 775 storage bootstrap/cache

cp /var/www/krayin/deploy/nginx/krayin.conf /etc/nginx/sites-available/krayin.conf
ln -sf /etc/nginx/sites-available/krayin.conf /etc/nginx/sites-enabled/krayin.conf
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

cp /var/www/krayin/deploy/supervisor/krayin-queue.conf /etc/supervisor/conf.d/
cp /var/www/krayin/deploy/supervisor/krayin-scheduler.conf /etc/supervisor/conf.d/

supervisorctl reread
supervisorctl update
supervisorctl start krayin-queue

(crontab -l ; echo "* * * * * php /var/www/krayin/artisan schedule:run") | crontab -

echo "Krayin instalado com sucesso no Ubuntu."
