COMPOSE_FILE	=	srcs/docker-compose.yml
USER			=	sravizza

all : setup build upd

setup:
	mkdir -p /home/$(USER)/data/mysql
	mkdir -p /home/$(USER)/data/wordpress

build:
	docker compose -f $(COMPOSE_FILE) build 

up:
	docker compose -f $(COMPOSE_FILE) up

upd:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

vdown:
	docker compose -f $(COMPOSE_FILE) down -v

stop:
	docker compose -f $(COMPOSE_FILE) stop

start:
	docker compose -f $(COMPOSE_FILE) start

nuke: vdown
	docker system prune -a --volumes -f

check:
	docker compose -f $(COMPOSE_FILE) ps
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all setup build up upd down vdown stop start nuke logs check
