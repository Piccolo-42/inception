# User Documentation

## Services overview

This stack provides a WordPress website accessible at `https://sravizza.42.fr`. Behind the scenes:

| Service 					| Role 
|---------------------------|------------------------------------------------------------------------
| **NGINX**					| Handles HTTPS (port 443), terminates TLS, proxies requests to WordPress
| **WordPress + PHP-FPM**	| Serves the website, processes PHP
| **MariaDB**				| Stores WordPress data (posts, users, settings)
| **Redis**					| Caches WordPress objects for faster page loads
| **Adminer**				| Web-based database management tool

## Starting and stopping

From the project root directory:

```bash
# Start the stack
make

# Stop the stack (containers removed, data preserved)
make down

# Restart
make re
```

After `make`, wait ~30 seconds for all services to initialize. WordPress needs MariaDB to be ready before it can complete setup.

## Accessing the website

| What 					| URL 
|-----------------------|----------------------------------
| WordPress site		| `https://sravizza.42.fr` 
| WordPress admin panel	| `https://sravizza.42.fr/wp-admin` 
| Adminer				| `https://sravizza.42.fr:8080` 
| Portainer				| `https://sravizza.42.fr:9443` 

Your browser will show a self-signed certificate warning — this is expected. Accept the warning to proceed.

**Note:** HTTP access (`http://sravizza.42.fr`) is intentionally disabled. Only HTTPS on port 443 works.

## Credentials

### Location

Passwords are stored in the `secrets/` directory at the project root:

| File								| Contains 
|-----------------------------------|--------------------------------------
| `secrets/wp_user_password.txt` 	| WordPress user password
| `secrets/wp_admin_password.txt`	| WordPress admin password 
| `secrets/db_password.txt` 		| MariaDB database user password 
| `secrets/db_root_password.txt`	| MariaDB root password 

Non-sensitive configuration (domain name, database name, usernames) lives in `srcs/.env`.

### Changing passwords

1. Stop the stack: `make down`
2. Edit the relevant file in `secrets/`
3. For database password changes, you may need to delete the MariaDB volume and let it reinitialize: `make fclean` then `make`
4. Restart: `make`

### WordPress admin login

Use the credentials from `secrets/credentials.txt` to log in at `https://sravizza.42.fr/wp-admin`. The admin username does **not** contain "admin" (as required by the subject).

### Adminer login

When logging into Adminer:
- **System:** MySQL
- **Server:** `mariadb` (the Docker service name, not `localhost`)
- **Username / Password:** from `srcs/.env` and `secrets/db_password.txt`
- **Database:** from `srcs/.env` (`MYSQL_DATABASE`)

## Checking that services are running

```bash
# See all running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Check logs for a specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb

# Verify the website responds
curl -k https://sravizza.42.fr
```

All containers should show `Up` status. If a container is restarting, check its logs for errors.

## Troubleshooting

| Symptom							| Likely cause 
|-----------------------------------|----------------------------------------------------------------------------
| Browser can't reach the site 		| Check that `sravizza.42.fr` is in your `/etc/hosts` file pointing to `127.0.0.1` 
| Certificate error					| Expected — self-signed cert. Accept the warning. 
| WordPress shows installation page | MariaDB may not be ready yet. Wait and refresh, or check MariaDB logs. 
| Adminer won't connect				| Make sure you're using `mariadb` as the server hostname, not `localhost` 
| Container keeps restarting		| Run `docker compose -f srcs/docker-compose.yml logs <service>` to see the error 
