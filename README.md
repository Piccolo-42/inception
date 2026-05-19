*This project has been created as part of the 42 curriculum by sravizza.*

# Inception

## Description

Inception is a system administration project that sets up a small web infrastructure using Docker containers orchestrated with Docker Compose. The stack runs entirely inside a virtual machine and includes:

- **NGINX** :				reverse proxy with TLSv1.2/TLSv1.3, sole entry point on port 443
- **WordPress + PHP-FPM** :	content management system
- **MariaDB** :				relational database backend

Each service runs in its own container, built from a custom Dockerfile based on `debian:bookworm`. Containers communicate through a dedicated Docker bridge network, and persistent data is stored in Docker named volumes mapped to `/home/sravizza/data/` on the host.

### Bonus services

- **Redis** :	object cache for WordPress, improving page load performance
- **Adminer** :	lightweight database management UI (accessible via NGINX on port 8080)

### Design choices

**Virtual Machines vs Docker**

A VM emulates an entire operating system with its own kernel, requiring significant resources (RAM, disk, CPU). Docker containers share the host kernel and only isolate the userspace, making them far lighter and faster to start. For this project, containers are the right abstraction: each service is a single process, not a full OS. The VM layer exists only because the school environment requires it.

**Secrets vs Environment Variables**

Environment variables (`.env`) store non-sensitive configuration like domain names and usernames. They are convenient but visible via `docker inspect` or `/proc/*/environ`. Docker secrets mount sensitive data (passwords, keys) as files under `/run/secrets/` inside the container, readable only by the container's processes. This project uses both: `.env` for config, secrets files for all passwords.

**Docker Network vs Host Network**

`network: host` removes network isolation — the container shares the host's network stack directly. A Docker bridge network (used here) creates an isolated virtual network where containers resolve each other by service name via Docker's internal DNS. This provides isolation, predictable inter-container routing, and prevents port conflicts on the host.

**Docker Volumes vs Bind Mounts**

Bind mounts map an arbitrary host path into the container, tightly coupling container to host filesystem layout. Named volumes are managed by Docker, portable, and support drivers. This project uses named volumes with a `device` option pointing to `/home/sravizza/data/` subdirectories, satisfying the subject requirement while keeping Docker volume management semantics.

## Instructions

### Prerequisites

- A Virtual Machine running Debian/Ubuntu (or WSL2 for development)
- Docker Engine and Docker Compose v2 installed
- `make` installed
- Entry in `/etc/hosts`: `127.0.0.1 sravizza.42.fr`

### Setup

1. Clone the repository
2. Create the secrets files in the `secrets/` directory:
   - `credentials.txt` — WordPress admin credentials
   - `db_password.txt` — MariaDB user password
   - `db_root_password.txt` — MariaDB root password
3. Create `srcs/.env` with required environment variables (see `DEV_DOC.md`)
4. Create data directories: `sudo mkdir -p /home/sravizza/data/mariadb /home/sravizza/data/wordpress`
5. Run `make` to build and start the stack
6. Open `https://sravizza.42.fr` in a browser (accept the self-signed certificate warning)

### Makefile targets

| Target				| What it does
|-----------------------|----------------------------------------------------------------------------------------------------------
| `make` / `make all`	| Creates data dirs, builds all images via `docker compose build`, starts stack with `docker compose up -d`
| `make down`			| `docker compose down` — stops and removes containers, network persists
| `make re`				| `make down` then `make all` — full rebuild
| `make clean`			| Stops containers, removes images and volumes
| `make fclean`			| `make clean` + removes host data directories

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB knowledge base](https://mariadb.com/kb/)
- [Debian Docker base images](https://hub.docker.com/_/debian)

### AI usage

AI (Claude by Anthropic) was used throughout the project as a learning and debugging assistant:

- **Conceptual understanding** — explaining Docker networking, PID 1, TLS configuration, and PHP-FPM pool management
- **Debugging** — diagnosing MariaDB crash loops, Docker Compose syntax errors, entrypoint script issues
- **Configuration review** — reviewing Dockerfiles, entrypoint scripts, and `docker-compose.yml` for correctness and compliance with subject constraints
- **Documentation** — assisting with drafting README, USER_DOC, and DEV_DOC structure

All AI-generated suggestions were reviewed, tested, and adapted to the specific project context. No code was blindly copy-pasted.