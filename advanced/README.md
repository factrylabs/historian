# Advanced Historian Docker compose file

This is a docker compose file for Factry Historian. It is based on the [Factry Historian Docker image](https://hub.docker.com/r/factry/historian). A cloud-init script is also included to automate the setup in a cloud environment.

## 🛠 Configuring Environment Variables

Configure Factry Historian with a `.env` file. Copy [.env.example](.env.example) to `.env` as a starting point.

### 🔹 Required Environment Variables

These have no defaults. `docker compose` refuses to start without them, so a missing password is a hard error rather than a blank one.

| Variable | Description |
|----------|-------------|
| `DB_PASSWORD` | PostgreSQL password (**Required**) |
| `INFLUXDB_ADMIN_PASSWORD` | InfluxDB admin password (**Required**) |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password (**Required**) |

```sh
DB_PASSWORD=mydbpass
INFLUXDB_ADMIN_PASSWORD=myinfluxpass
GF_SECURITY_ADMIN_PASSWORD=mygrafanapass
JWT_SECRET=...
```

🚨 Keep the `.env` file. Docker Compose reads it on every invocation, including a plain `docker compose up -d` after a reboot or an upgrade. Passing the passwords on the command line instead leaves the next invocation with nothing to read, which breaks the deployment. `.env` is in `.gitignore`; do not commit it.

---

### 🔹 Optional Configuration Variables

These have default values but can be overridden.

#### **For Factry Historian**

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `v8.1.9` | Factry Historian version to use |
| `AUTO_MIGRATE` | `true` | Migrate the database automatically on start |
| `DB_NAME` | `factry_historian` | PostgreSQL database name |
| `DB_USER_NAME` | `factry` | PostgreSQL username |
| `JWT_SECRET` | generated | Key used to encrypt secure settings. When unset, the server generates one into `/var/opt/factry/jwt_secret` in the `historian` volume. See [The JWT secret](#-the-jwt-secret) |
| `GRPC_PORT` | `8001` | gRPC port, used by remote collectors |
| `GRPC_BIND_ADDRESS` | `0.0.0.0` | gRPC bind address. Historian terminates TLS on this port itself, so it is normally published directly |
| `REST_PORT` | `8000` | REST API port |
| `REST_BIND_ADDRESS` | `0.0.0.0` | REST API bind address. The REST API serves plain HTTP, so set this to `127.0.0.1` and put a TLS terminating reverse proxy in front of it on any host that is not on a trusted network |

#### **For Grafana**

| Variable | Default | Description |
|----------|---------|-------------|
| `GF_VERSION` | `13.0.2` | Grafana OSS version. Grafana's database migrations are forward-only; a major upgrade cannot be rolled back without restoring the `grafana` volume |
| `GF_HISTORIAN_PLUGIN_VERSION` | `3.3.0` | Version of the [Factry Historian datasource plugin](https://grafana.com/grafana/plugins/factry-historian-datasource/) to install. Requires Grafana 11.6.0 or newer |
| `GF_SERVER_ROOT_URL` | `http://127.0.0.1` | Grafana root URL. A path here (for example `https://host/grafana`) is served correctly without further configuration: the compose file pins `GF_SERVER_SERVE_FROM_SUB_PATH` on, which is a no-op for a path-free URL |
| `GRAFANA_PORT` | `3000` | Grafana server port |
| `GF_AUTH_ANONYMOUS_ENABLED` | `false` | Enable anonymous access |
| `GF_AUTH_ANONYMOUS_ORG_NAME` | `Factry` | Organization for anonymous users |
| `GF_BIND_ADDRESS` | `0.0.0.0` | Grafana bind address. Set to `127.0.0.1` when Grafana sits behind a reverse proxy |

#### **For InfluxDB**

| Variable | Default | Description |
|----------|---------|-------------|
| `INFLUXDB_ADMIN_USER` | `factry` | InfluxDB admin username |

---

## 🔑 Rotating the InfluxDB admin password

`INFLUXDB_ADMIN_USER` and `INFLUXDB_ADMIN_PASSWORD` are only applied by the InfluxDB entrypoint when the data directory is empty. Changing `INFLUXDB_ADMIN_PASSWORD` in `.env` and running `docker compose up -d` does **not** rotate the stored credential: the old password keeps working and Historian's saved connection keeps working, which makes the rotation look successful when it did nothing.

To actually rotate it:

```sh
# Read the admin user out of the container, so this is right even when
# INFLUXDB_ADMIN_USER has been overridden.
user=$(docker compose exec -T influxdb printenv INFLUXDB_ADMIN_USER | tr -d '\r')

docker compose exec -T influxdb influx \
  -username "$user" -password '<old-password>' \
  -execute "SET PASSWORD FOR \"$user\" = '<new-password>'"
```

Then update `INFLUXDB_ADMIN_PASSWORD` in `.env` and update the time series database connection under **Configuration > Time Series Databases** in Historian.

---

## 🔐 The JWT secret

Secure settings, such as collector tokens, time series database passwords and authentication provider secrets, are encrypted with a JWT secret.

- If `JWT_SECRET` is not set, the server generates one and stores it in `/var/opt/factry/jwt_secret`, inside the `historian` volume.
- If it is set, the server uses that value and writes no file.

Set it explicitly. It then lives in `.env` with the rest of the credentials, it is covered by whatever backs `.env` up, and the `migrate` subcommand can use it. That last point matters: `migrate` does **not** read `/var/opt/factry/jwt_secret`, and without the environment variable it fails partway through with

```
error executing post hook for version 6030006 : no JWT secret provided for encrypting secure settings
```

On a **new** deployment, generate one:

```sh
echo "JWT_SECRET=$(openssl rand -base64 32)" >> .env
```

On an **existing** deployment, read out the secret the server already generated and use that value. Using a different one re-encrypts secure settings with a key the server cannot read back:

```sh
# Ask Docker which volume is mounted at /var/opt/factry, rather than assuming
# the compose project name that prefixes it.
vol=$(docker inspect -f \
  '{{range .Mounts}}{{if eq .Destination "/var/opt/factry"}}{{.Name}}{{end}}{{end}}' \
  "$(docker compose ps -q historian)")
docker run --rm -v "$vol:/d" alpine cat /d/jwt_secret
```

Back `.env` up. Losing the secret makes every stored secure setting unreadable.

---

## ⬆️ Upgrading

```sh
# Back up first. Both Historian and Grafana run forward-only migrations.
docker compose exec postgres sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  > historian-$(date +%F).sql

# Then raise VERSION (and GF_VERSION) in .env and apply.
docker compose pull
docker compose up -d
```

---

## ☁️ Cloud-init

[user-data.sh](user-data.sh) provisions an Ubuntu 24.04 LTS machine with Docker, Caddy and this compose file. Caddy terminates TLS for the Historian web UI on `https://<fqdn>` and for Grafana on `https://<fqdn>/grafana`, so the script binds the REST API and Grafana to loopback. The collector gRPC endpoint stays published on port 8001, where Historian terminates TLS itself.

It writes the generated credentials, including `JWT_SECRET`, to `~/.env` next to the compose file.

Caddy needs a name that resolves publicly to the instance in order to obtain a certificate. The script checks that `hostname -f` returns a qualified name and stops if it does not, but it cannot tell whether that name actually points here, so a certificate can still fail afterwards. It prints where to look (`journalctl -u caddy -e`) rather than claiming the site is up.

By default it fetches `advanced/docker-compose.yml` from the `main` branch, which means a machine provisioned today and one provisioned next month can differ. Set `COMPOSE_REF` to a release tag to pin it:

```sh
COMPOSE_REF=<tag> ./user-data.sh
```

Pick a tag that contains the compose file you want; the existing `v1.0.0` predates the current one.
