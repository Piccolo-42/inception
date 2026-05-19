# Developer Documentation

## Prerequisites

- **OS:**					Debian-based Linux (or WSL2 for development)
- **Docker Engine:**		v20.10+ with Docker Compose v2
- **make:**					GNU Make
- **openssl:**				for generating self-signed TLS certificates (done at NGINX build time)
- **Domain resolution:**	`sravizza.42.fr` must resolve to `127.0.0.1`

### Installing Docker (on a fresh Debian VM)

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect
```

## Setting up the environment from scratch

### 1. Clone the repository

```bash
git clone <repo-url>
cd inception
```

### 2. Create the `.env` file

Create `srcs/.env` with the following variables:

```
USER=stef42

DOMAIN_NAME=sravizza.42.fr

DB_NAME=wordpress
DB_USER=wpuser

WP_TITLE=Inception
WP_ADMIN_USER=superuser
WP_ADMIN_EMAIL=superuser@sravizza.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@sravizza.42.fr
```

**Important:** `DOMAIN_NAME` must be a plain hostname — no `https://` prefix.

### 3. Create secrets files

```bash
mkdir -p secrets
echo "your_db_password_here" > secrets/db_password.txt
echo "your_db_root_password_here" > secrets/db_root_password.txt
echo "your_wp_admin_password_here" > secrets/credentials.txt
```

Make sure these files are in `.gitignore` and never committed.

### 4. Create host data directories

```bash
sudo mkdir -p /home/sravizza/data/mariadb
sudo mkdir -p /home/sravizza/data/wordpress
sudo chown -R $USER:$USER /home/sravizza/data
```

### 5. Configure DNS resolution

Add to `/etc/hosts`:

```
127.0.0.1   sravizza.42.fr
```

On Windows (WSL2 development): edit `C:\Windows\System32\drivers\etc\hosts`.

## Building and launching

### Makefile targets

| Target				| What it does
|-----------------------|----------------------------------------------------------------------------------------------------------
| `make` / `make all`	| Creates data dirs, builds all images via `docker compose build`, starts stack with `docker compose up -d`
| `make down`			| `docker compose down` — stops and removes containers, network persists
| `make re`				| `make down` then `make all` — full rebuild
| `make clean`			| Stops containers, removes images and volumes
| `make fclean`			| `make clean` + removes host data directories

### Manual Docker Compose commands

All commands must specify the compose file path:

```bash
# Build
docker compose -f srcs/docker-compose.yml build

# Start
docker compose -f srcs/docker-compose.yml up -d

# Stop
docker compose -f srcs/docker-compose.yml down

# Rebuild a single service
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d wordpress
```

## Managing containers and volumes

```bash
# List running containers
docker compose -f srcs/docker-compose.yml ps

# View logs (follow mode)
docker compose -f srcs/docker-compose.yml logs -f nginx

# Execute a command inside a container
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p

# List volumes
docker volume ls

# Inspect a volume (verify mountpoint)
docker volume inspect srcs_mariadb_data

# List the custom network
docker network ls
docker network inspect srcs_inception_network
```

## Project structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                          # NOT in git
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                          # NOT in git
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/entrypoint.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/entrypoint.sh
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/redis.conf
            └── adminer/
	    		└── Dockerfile
```

## Data persistence

### Where data lives

| Volume			| Container mount	| Host path
|-------------------|-------------------|--------------------------------
| `mariadb_data`	| `/var/lib/mysql`	| `/home/sravizza/data/mariadb`
| `wordpress_data`	| `/var/www/html`	| `/home/sravizza/data/wordpress`

These are Docker **named volumes** with a `local` driver using the `device` option to bind to specific host paths. They are defined in `docker-compose.yml` under the top-level `volumes:` key.

### How persistence works

- Volumes survive `docker compose down` — only `docker volume rm` or `make fclean` deletes them.
- After a VM reboot, running `make` again brings the stack back with all data intact (posts, users, uploads, database).
- MariaDB's entrypoint checks whether `/var/lib/mysql` already contains data. If it does, it skips initialization and starts normally.
- WordPress's entrypoint checks whether `wp-config.php` exists. If it does, it skips `wp core install` and just launches PHP-FPM.

### Wiping data for a clean start

```bash
make fclean
# This removes containers, images, volumes, AND host data directories
make
# Fresh initialization from scratch
```

## Key implementation details

- **PID 1:** Each container runs its main process (nginx, php-fpm, mariadbd) as PID 1 in foreground mode. Docker monitors PID 1 — when it exits, the container stops.
- **Restart policy:** All containers use `restart: on-failure` so they recover from crashes.
- **Secrets:** Mounted read-only at `/run/secrets/<name>` inside containers. Entrypoint scripts read them with `$(cat /run/secrets/<name>)`.
- **No `latest` tag:** All base images use specific version tags (e.g., `debian:bookworm`).
- **No infinite loops:** No `tail -f`, `sleep infinity`, or `while true` anywhere in the project.