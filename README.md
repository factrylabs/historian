# Factry Historian - Docker Compose Quick Start

This repository provides a Docker Compose setup for Factry Historian, allowing you to quickly deploy a Historian server along with PostgreSQL, InfluxDB, and Grafana.

## 🚀 Quick Setup

If you want to get started as quickly as possible, just run:

```sh
git clone https://github.com/factrylabs/historian
cd historian
docker compose up -d
```

✅ No environment variables needed<br>
✅ Everything runs with default values<br>
✅ Access the services:<br>
- **Factry Historian** → [http://localhost:8000](http://localhost:8000) (Default login: `factry` / `password`)
- **Grafana** → [http://localhost:3000](http://localhost:3000) (Login: `admin` / `admin`)

InfluxDB and PostgreSQL are only reachable from the other containers. They are addressed as `influx:8086` and `postgres:5432` on the Compose network and are deliberately not published to the host.

🚨 **Important:**
This quick setup uses well-known default passwords and publishes ports 8000, 8001 and 3000 on every network interface. Run it on a local machine only. For any host that other people can reach, use the [advanced setup](advanced), which refuses to start unless passwords are supplied.

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

## Advanced Setup

In the [advanced](advanced) directory, you'll find a more customizable docker compose setup with environment variables for configuration and a cloud-init script to automate the setup in a cloud environment. Use it for anything other than a local trial.

---

## ❓ Questions?

For help, visit:
📌 **Factry Community**  https://www.reddit.com/r/Factry/
