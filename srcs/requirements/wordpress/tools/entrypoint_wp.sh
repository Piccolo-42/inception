#!/bin/bash

sleep 5

 if [ ! -f "/var/www/html/wp-config.php" ]; then

	DB_PASSWORD=$(cat /run/secrets/db_password)
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
	WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

	wp core download --allow-root

	wp config create --allow-root \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="mariadb:3306"

	wp config set WP_REDIS_HOST 'redis' --allow-root
	wp config set WP_REDIS_PORT 6379 --raw --allow-root

	wp core install --allow-root \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}"

	wp user create --allow-root \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}" 

	wp plugin install redis-cache --activate --allow-root
	wp redis enable --allow-root


	#wp theme install hf-lite --activate --allow-root
	#wp theme mod set blogdescription "Les Containers des Mille et une Nuits" --allow-root
	wp option update siteurl "https://${DOMAIN_NAME}" --allow-root
	wp option update home "https://${DOMAIN_NAME}" --allow-root
	wp rewrite structure '/%postname%/' --allow-root

	chown -R www-data:www-data /var/www/html
fi

exec php-fpm8.2 -F
