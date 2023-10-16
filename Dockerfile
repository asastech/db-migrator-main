FROM flyway/flyway:9.22.3-alpine

LABEL org.opencontainers.image.source = &quot;https://github.com/asastech/db-migrator-main&quot;

WORKDIR /migrations

COPY . .

ENTRYPOINT [ "./executor.sh" ]
