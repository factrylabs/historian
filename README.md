# Historian Docker compose file

This is a docker compose file for Factry Historian. It is based on the [Factry Historian Docker image](https://hub.docker.com/r/factry/historian).

# 1. Installing Factry Historian via Docker

## Cloning the repo
Clone this repo and cd into it:
```
git clone https://github.com/factrylabs/historian
cd historian
```

## Spinning up the Docker environment

Use the following command to pass the required environment variables and get started quickly, or [change additional configuration values](#configuring-the-environment-variables).

```
env DB_PASSWORD=<mydbpass> INFLUXDB_ADMIN_PASSWORD=<myinfluxadminpass> GF_SECURITY_ADMIN_PASSWORD=<mygrafanaadminpass> docker compose up
```


## Configuring the environment variables
This repository's `docker-compose.yml` file supports the environment variables mentioned below.

Only `DB_PASSWORD`, `INFLUXDB_ADMIN_PASSWORD` and `GF_SECURITY_ADMIN_PASSWORD` are required. All others have a default set, which you can override.

### For Factry Historian:
* DB_PASSWORD: The PostgreSQL password. **Must be set**.
* VERSION: the Factry Historian version to download. Defaults to `latest`.
* AUTO_MIGRATE: whether to automatically perform migrations to the installable version of Factry Historian. Useful when up- or downgrading. Defaults to `true`.
* DB_NAME: The PostgreSQL database name. Defaults to `factry_historian`.
* DB_USER_NAME: The PostgreSQL username. Defaults to `factry`.
* GRPC_PORT: The gRPC port used for communication between data collectors and Factry Historian. Defaults to `8001`.
* GRPC_BIND_ADDRESS: The bind address for the gRPC port. Defaults to `0.0.0.0`.
* REST_PORT: The HTTP/REST API port used for communication between data collectors and Factry Historian. Defaults to `8000`.
* REST_BIND_ADDRESS: The bind address for the HTTP/REST API port. Defaults to `0.0.0.0`.

### For Grafana:
* GF_SECURITY_ADMIN_PASSWORD: Default admin password, can be changed before first start of grafana, or in profile settings. **Must be set**.
* GF_VERSION: The Grafana OSS version to install. Defaults to `latest`.
* GF_SERVER_ROOT_URL: The Grafana root url. Defaults to `http://127.0.0.1`
* GRAFANA_PORT: The port where Grafana will run. Defaults to `3000`.
* GF_AUTH_ANONYMOUS_ENABLED: Whether [anonymous authentication](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/anonymous-auth/) is enabled. Defaults to `false`.
* GF_AUTH_ANONYMOUS_ORG_NAME: Organization name that should be used for unauthenticated users. See [anonymous authentication](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/anonymous-auth/). Defaults to `Factry`.
* GF_BIND_ADDRESS: The bind address for the Grafana server. Defaults to `0.0.0.0`.

### For InfluxDB:
* INFLUXDB_ADMIN_PASSWORD: The InfluxDB v1 admin password. **Must be set**.
* INFLUXDB_ADMIN_USER: The InfluxDB v1 admin username. Defaults to `factry`.

# 2. Configuring Factry Historian via the browser

Open your browser and go to the address where you configured Factry Historian to run e.g. http://localhost:8000.

The default username and password is factry/password. You will have to change it immediately after your first login.

## 1. Welcome
The Setup wizard opens. Click **Next**.

## 2. License
Choose **Activate a license** if you have obtained a license from Factry. If you need one, please contact us at info@factry.io to obtain pricing information.

OR

Tick the box to accept the *End User License Agreement* and click **Start trial**. Factry Historian will work for 2 hours, after which it will shut down. You can restart Factry Historian as much as you want.

## 3. Organization
Configure your first Organization. You can leave the defaults, or change at will. Configure a password for the PostgreSQL read-only user that will be autocreated for this organization. This user will have access to all event views that are autocreated.

A Factry Historian server can support multiple organizations, for example 1 per production site in the case of company-wide deployments, or 1 organization per area in the plant.

## 4. Internal database
The internal database is used to store log information from Factry Historian itself, as well as all data collectors. Configure the credentials as in the `docker-compose.yml` file:

* Admin user: equal to $INFLUXDB_ADMIN_USER
* Admin password: equal to $INFLUXDB_ADMIN_PASSWORD
* Host: the hostname of the InfluxDB server. When configuring via docker, the Host will be at `http://influx:8086`.
* Database: pick an internal database name, or leave the default `_internal_factry`.
* Read only user: choose a username for the read-only user with access to the Database.
* Read only password: choose a password for the read-only user with access to the Database.
* Create database: select if you would like the wizard to autocreate this database. Defaults to `yes`.

## 5. Historian Configuration
### API
* GRPC port: equal to $GRPC_PORT
* REST port: equal to $REST_PORT
* URL: This value will be used by the data collectors to connect to the Factry Historian server API. As such, this URL needs to be resolvable from the host where the collector will run. When using [collectors that run in Docker](#4-installing-a-first-data-collector) on MacOS, a good default is `http://host.docker.internal`.
### Authentication
* Session inactive duration: The time after which an inactive login session expires. This setting accepts duration string literals, eg 1w2d7h15m (1 week 2 days 7 hours and 15 minutes).
* Base URL: The URL on which the Factry Historian frontend is available. This setting is important in order for Google and/or Microsoft authentication providers to work.

See https://docs.factry.cloud/docs/historian/latest/3_administration/general/ for more information.

## 6. Finished
All done!

# 3. Configuring a time-series database

Once logged in to the Factry Historian user interface as an administrator, navigate to `Configuration > Time Series Databases`. Create your first database according to this manual: https://docs.factry.cloud/docs/historian/latest/5_time_series_databases/time-series-databases/

For example, you could use:
* Name: historian
* Admin user: equal to $INFLUXDB_ADMIN_USER
* Admin password: equal to $INFLUXDB_ADMIN_PASSWORD
* Host: http://influx:8086 when using Docker's defaults
* Database: historian
* Read only user: historian
* Read only password: uptoyou

Then click **Save & test**.

# 4. Installing a first data collector

Once a time-series database has been configured (see [Configuring a time-series database](#3-configuring-a-time-series-database)), navigate to `Collectors` and click `Create collector`. For example, you could use:
* Name: opc-ua collector
* Description: my first opc-ua collector
* Default database: historian (which you created above)

Then click **Submit**.

The collector you just created is now in an initial state ([ ]). Select the collector from the list and click `Generate token`. Copy this token to the clipboard.

with the installThen proceed ation of your collector according to the README at https://github.com/factrylabs/collector. Pass the copied token as `API_TOKEN`.

For example:
```
docker run -d --restart unless-stopped --name factry-collector -e API_TOKEN=<API_TOKEN> -e PRODUCT=opc-ua ghcr.io/factrylabs/collector:latest
```

The collector will now start in Docker and connect to the Factry Historian server. Further configuration can be done in the Factry Historian user interface, which by default will be running at http://localhost:8000/.

# Questions?
In case of questions, please create a post on https://www.reddit.com/r/Factry/.
