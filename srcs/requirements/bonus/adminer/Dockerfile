FROM debian:bookworm

RUN apt-get update && apt-get install -y php php-mysqli php-mbstring wget && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer

RUN wget https://github.com/vrana/adminer/releases/download/v5.4.2/adminer-5.4.2.php \
    -O /var/www/adminer/index.php 

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
