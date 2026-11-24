# WordPress + MariaDB + Mailpit (Docker Compose)

A ready-to-use local WordPress development stack:

- **WordPress** (latest official image) with Apache, HTTP and HTTPS (self-signed certificate)
- **MariaDB 11** as the database
- **Mailpit** to catch every email sent by WordPress (nothing leaves your machine)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose v2

## Quick start

```bash
docker compose up -d --build
```

Then open:

| Service        | URL                      | Notes                                  |
| -------------- | ------------------------ | -------------------------------------- |
| WordPress      | http://localhost:8080    | Runs the WordPress install wizard      |
| WordPress SSL  | https://localhost:8443   | Self-signed certificate (browser warning is expected) |
| Mailpit web UI | http://localhost:8025    | Inbox for all outgoing emails          |

## Architecture

| Service     | Container      | Image                  | Exposed ports            |
| ----------- | -------------- | ---------------------- | ------------------------ |
| `db`        | `wp-mariadb`   | `mariadb:11`           | none (internal `3306`)   |
| `wordpress` | `wp-wordpress` | built from `Dockerfile` | `8080` (HTTP), `8443` (HTTPS) |
| `mailpit`   | `wp-mailpit`   | `axllent/mailpit`      | `8025` (web UI); SMTP `1025` internal only |

`wordpress` waits for `db` to be healthy before starting.

### Custom WordPress image

The [Dockerfile](Dockerfile) extends `wordpress:latest` to:

- enable Apache `mod_ssl` and the `default-ssl` site, with a self-signed certificate valid for 10 years (`localhost`, `127.0.0.1`)
- install `msmtp` and configure PHP's `sendmail_path` so that `wp_mail()` relays through Mailpit (`mailpit:1025`, no TLS)

No SMTP plugin is needed: emails sent by WordPress show up in Mailpit automatically.

## Configuration

Default credentials (defined in [docker-compose.yml](docker-compose.yml)):

| Setting        | Value          |
| -------------- | -------------- |
| Database name  | `wordpress`    |
| Database user  | `wordpress`    |
| Database pass  | `wordpress`    |
| Root password  | `rootpassword` |
| DB host (from WordPress) | `db:3306` |

> **These values are for local development only.** Change them before exposing the stack anywhere else.

## Data and persistence

Everything is stored in bind-mounted folders under `./data`:

| Path               | Content                       |
| ------------------ | ----------------------------- |
| `data/mariadb/`    | MariaDB database files        |
| `data/wordpress/`  | WordPress files (core, `wp-content`, `wp-config.php`) |
| `data/mailpit/`    | Mailpit message database      |

The [.gitignore](.gitignore) excludes databases, mails, WordPress core, `wp-config.php` (contains passwords) and uploads. Only your own code in `wp-content/themes`, `wp-content/plugins` and `wp-content/mu-plugins` is meant to be versioned (the default themes and plugins are ignored).

## Common commands

```bash
docker compose up -d --build   # start (and rebuild the WordPress image)
docker compose logs -f         # follow logs
docker compose ps              # list services
docker compose stop            # stop without removing containers
docker compose down            # stop and remove containers (data is kept)
```

Reset everything (**deletes the database, WordPress files and mails**):

```bash
docker compose down
rm -rf data/mariadb data/wordpress data/mailpit
```

## Testing emails

1. In WordPress, trigger any email (e.g. *Lost your password?* on the login page, or *Settings → General → Administration Email Address*).
2. Open http://localhost:8025 — the message appears immediately in Mailpit.

## Troubleshooting

- **Port already in use**: change the left side of the port mappings in `docker-compose.yml` (e.g. `"8081:80"`).
- **Browser warns about HTTPS**: expected with a self-signed certificate; accept the exception for `localhost`.
- **Site URL issues after changing the port**: update *Settings → General* (WordPress/Site Address) or `WP_HOME` / `WP_SITEURL` in `wp-config.php`.
- **MariaDB fails to start after a crash**: check `docker compose logs db`; as a last resort, reset the data as shown above.

## License

See [LICENSE](LICENSE).
