FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint_mdb.sh /usr/local/bin/entrypoint_mdb.sh
RUN chmod +x /usr/local/bin/entrypoint_mdb.sh

RUN rm -rf /var/lib/mysql/*

EXPOSE 3306

ENTRYPOINT ["entrypoint_mdb.sh"]
