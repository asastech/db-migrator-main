# DB Migrations

This repository contains the [Flyway][flyway] migrations used to define Asasy databases.

## Structure

The migrations are organised into folders according to the database they belong to.

> **Note:** There is a special `init-db` folder which contains migrations that are used on every new database.

Each database folder contains a `flyway.conf` [configuration file][flyway-conf] to configure the mgirations.

## General guidelines

The are some general guidelines that are followed in the design of the databases & migrations:

- Permission to create tables is restricted to the DB migrator service account.
- The default `PUBLIC` role is restricted.
- Table-level `SELECT`, `INSERT`, `UPDATE`, and `DELETE` permissions are granted to non-login roles.

### Example simplified permission structure

| Role           | Type            | Connect to database | Create tables | Member of       |
| -------------- | --------------- | ------------------- | ------------- | --------------- |
| postgres       | user (Postgres) | Yes, all            | Yes           | `{superuser}`   |
| db-migrator    | user            | Yes, all            | Yes           | `{}`            |
| loki_user      | role            | No                  | No            | `{}`            |
| loki_service   | user            | Yes, `{loki}`       | No            | `{loki_user}`   |

## Running the migrations

In order to run the migrations, you must supply the necessary credentials to connect to the database.

### Locally

1. Make sure your database is running:

```bash
sudo service postgresql start
```

2. Navigate to the directory of the database migrations you would like to run:

```bash
cd ./loki
```

3. Run the migration script (supplying a `.env` file if necessary):

```bash
./migrate.sh
```

### Docker Compose

Use `docker-compose` to bring up the migrator and a test db:

```bash
docker-compose up -f docker-compose.dev.yml
```

### Linting

We use [SQLFluff linter][sqlfluff] to lint and fix our database migrations. The `lint.sh` script will traverse all folders except init-db and will apply lint rules/fixes on any `.sql` files. To run locally:

```bash
$ pip install -r lint-requirements.txt
# install sqlfluff

$ CONCURRENCY=2 bash lint.sh
# will use 2 threads to lint files

$ CONCURRENCY=4 bash lint.sh -f
# will use 4 threads to fix errors
```

The default dialect used is `postgres`.

[flyway]: https://flywaydb.org/
[flyway-conf]: https://flywaydb.org/documentation/configuration/configfile
[sqlfluff]: https://sqlfluff.com/
