FROM flyway/flyway:10.8.1-alpine


LABEL org.opencontainers.image.source = &quot;https://github.com/asastech/db-migrator-main&quot;

WORKDIR /migrations

COPY . .

ENTRYPOINT [ "./executor.sh" ]
