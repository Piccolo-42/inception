COMPOSE_FILE	=	srcs/docker-compose.yml
DATA_DIR		=	/home/stef42/data

all : setup build

setup:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build:
	@docker compose -f $(COMPOSE_FILE) up --build -d

down:
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

start:
	@docker compose -f $(COMPOSE_FILE) start

clean: stop
	@docker image prune -af

fclean: down
	@docker volume rm $(shell docker volume ls -q) 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR)

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all setup build down stop start clean fclean re logs
