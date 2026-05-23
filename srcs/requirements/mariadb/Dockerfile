FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/* && rm -rf /var/lib/mysql/*

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint_mdb.sh /usr/local/bin/entrypoint_mdb.sh
RUN chmod +x /usr/local/bin/entrypoint_mdb.sh

HEALTHCHECK --start-period=7s --interval=20s --timeout=15s --retries=3 \
	CMD mariadb -u $DB_USER -p$(cat /run/secrets/db_password) --execute="SELECT 1;" || exit 1

EXPOSE 3306

ENTRYPOINT ["entrypoint_mdb.sh"]
