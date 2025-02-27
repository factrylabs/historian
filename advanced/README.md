# Advanced Historian Docker compose file

This is a docker compose file for Factry Historian. It is based on the [Factry Historian Docker image](https://hub.docker.com/r/factry/historian). A cloud-init script is also included to automate the setup in a cloud environment.

## 🛠 Configuring Environment Variables

You can customize Factry Historian by defining environment variables in a `.env` file or passing them in the docker-compose command.

### 🔹 Required Environment Variables

The following must be set if you’re not using the default setup:

| Variable | Description |
|----------|-------------|
| `DB_PASSWORD` | PostgreSQL password (**Required**) |
| `INFLUXDB_ADMIN_PASSWORD` | InfluxDB admin password (**Required**) |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password (**Required**) |

#### Example: Running with Custom Passwords

```sh
env DB_PASSWORD=mydbpass INFLUXDB_ADMIN_PASSWORD=myinfluxpass GF_SECURITY_ADMIN_PASSWORD=mygrafanapass docker compose up -d
```

**OR**, create a `.env` file:

```sh
DB_PASSWORD=mydbpass
INFLUXDB_ADMIN_PASSWORD=myinfluxpass
GF_SECURITY_ADMIN_PASSWORD=mygrafanapass
```

Then run:

```sh
docker compose --env-file .env up -d
```

---

### 🔹 Optional Configuration Variables

These have default values but can be overridden.

#### **For Factry Historian**

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `latest` | Factry Historian version to use |
| `AUTO_MIGRATE` | `true` | Auto-perform migrations |
| `DB_NAME` | `factry_historian` | PostgreSQL database name |
| `DB_USER_NAME` | `factry` | PostgreSQL username |
| `GRPC_PORT` | `8001` | gRPC port |
| `GRPC_BIND_ADDRESS` | `0.0.0.0` | gRPC bind address |
| `REST_PORT` | `8000` | REST API port |
| `REST_BIND_ADDRESS` | `0.0.0.0` | REST API bind address |

#### **For Grafana**

| Variable | Default | Description |
|----------|---------|-------------|
| `GF_VERSION` | `latest` | Grafana OSS version |
| `GF_SERVER_ROOT_URL` | `http://127.0.0.1` | Grafana root URL |
| `GRAFANA_PORT` | `3000` | Grafana server port |
| `GF_AUTH_ANONYMOUS_ENABLED` | `false` | Enable anonymous access |
| `GF_AUTH_ANONYMOUS_ORG_NAME` | `Factry` | Organization for anonymous users |
| `GF_BIND_ADDRESS` | `0.0.0.0` | Grafana bind address |

#### **For InfluxDB**

| Variable | Default | Description |
|----------|---------|-------------|
| `INFLUXDB_ADMIN_USER` | `factry` | InfluxDB admin username |
