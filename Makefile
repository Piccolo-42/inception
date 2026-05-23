COMPOSE_FILE	=	srcs/docker-compose.yml
USER			=	sravizza

all : build upd

build:
	sudo docker compose -f $(COMPOSE_FILE) build 

up:
	sudo docker compose -f $(COMPOSE_FILE) up

upd:
	sudo docker compose -f $(COMPOSE_FILE) up -d

down:
	sudo docker compose -f $(COMPOSE_FILE) down

vdown:
	sudo docker compose -f $(COMPOSE_FILE) down -v

stop:
	sudo docker compose -f $(COMPOSE_FILE) stop

start:
	sudo docker compose -f $(COMPOSE_FILE) start

nuke: vdown
	sudo docker system prune -a --volumes -f

check:
	sudo docker compose -f $(COMPOSE_FILE) ps
logs:
	sudo docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all build up upd down vdown stop start nuke logs check
