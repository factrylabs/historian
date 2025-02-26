# Factry Historian - Docker Compose Setup

This repository provides a Docker Compose setup for Factry Historian, allowing you to quickly deploy a Historian server along with PostgreSQL, InfluxDB, and Grafana.

## 🚀 Quick Setup

If you want to get started as quickly as possible, just run:

```sh
git clone https://github.com/factrylabs/historian
cd historian
docker compose up -d
```

✅ No environment variables needed  
✅ Everything runs with default values  
✅ Access the services:
- **Factry Historian** → [http://localhost:8000](http://localhost:8000) (Default login: `factry` / `password`)
- **Grafana** → [http://localhost:3000](http://localhost:3000) (Login: `admin` / `admin`)
- **InfluxDB** → [http://localhost:8086](http://localhost:8086) 
- **PostgreSQL** → `localhost:5432` (User: `factry`, Password: `password`)

🚨 **Important:**
This quick setup uses default passwords and should not be used for production. See the next section for customizing the setup.

## 🔧 Configuring Factry Historian via the Browser

Once the services are running, open Factry Historian at:
👉 [http://localhost:8000](http://localhost:8000)

### 🛠 Setup Steps

1. **Login** → Default username: `factry`, password: `password` (**change immediately**).
2. **Activate a License** (or start a trial).
3. **Set Up an Organization** → Choose a name & configure PostgreSQL access.
4. **Connect to Internal Database** → Use for this docker:
   - **Host:** `http://influx:8086`
   - **Admin User:** `factry`
   - **Admin Password:** `password`
5. **Historian Configuration** → Ensure correct API & authentication settings.
6. **Finish Setup** 

---

## 📊 Configuring a Time-Series Database

1. Go to **Configuration > Time Series Databases**.
2. Create a database with:
   - **Name:** `historian`
   - **Admin User:** `factry`
   - **Admin Password:** `password`
   - **Host:** `http://influx:8086`
   - **Database:** `historian`
3. Click **Save & Test**.

---

## 📡 Installing a Data Collector

1. Navigate to **Collectors** in Factry Historian.
2. Click **Create Collector** → e.g., OPC-UA Collector.
3. Click **Generate Token** and copy it.
4. Then proceed with the installation of your collector according to the README at https://github.com/factrylabs/collector. 
5. Pass the copied token as API_TOKEN.
6. Run the collector with:

```sh
docker run -d --restart unless-stopped --name factry-collector -e API_TOKEN=<API_TOKEN> -e PRODUCT=opc-ua ghcr.io/factrylabs/collector:latest
```

---

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


---

## ❓ Questions?

For help, visit:
📌 **Factry Community**  https://www.reddit.com/r/Factry/


