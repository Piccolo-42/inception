FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server && \
	rm -rf /var/lib/apt/lists/*

EXPOSE 6379

HEALTHCHECK --interval=5s --timeout=3s --retries=5 --start-period=10s \ 
	CMD redis-cli ping || exit 1

CMD ["redis-server", "--protected-mode", "no"]
