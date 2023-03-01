FROM flyway/flyway:9.15.1-alpine

LABEL org.opencontainers.image.source = &quot;https://github.com/oofin-engineering/db-migrator&quot;

WORKDIR /migrations

COPY . .

ENTRYPOINT [ "./executor.sh" ]
