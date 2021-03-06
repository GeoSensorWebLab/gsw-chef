# `asw-etl` cookbook

Cookbook for setting up a node with Arctic Sensor Web ETL:

* Nginx
  - For restricting access to Apache Airflow
* [GSW Data Transloader][data-transloader]
  - for bringing external sensor data into [OGC SensorThings API][STA]
* [Apache Airflow][airflow] 1.10.10
  - for monitoring/scheduling Data Transloader

This cookbook is based on the `blackfoot` node cookbook. This node is intended to run on AWS EC2.

When ran in local development mode, Test Kitchen will also install FROST Server (from the `gsw-frost-server` cookbook) for a temporary database. This is only used as a safe non-production database; when deployed to AWS, the ETL should be pointed to a separately-hosted OGC SensorThings API instance. For our production usage, we run Amazon API Gateway with EC2 (FROST Server on Docker) and RDS for hosting OGC SensorThings API.

Arctic Sensor Web is a part of the [Arctic Connect platform][arcticconnect].

[airflow]: https://airflow.apache.org
[arcticconnect]: https://www.arcticconnect.ca
[data-transloader]: https://github.com/GeoSensorWebLab/data-transloader/
[STA]: https://www.ogc.org/standards/sensorthings

## Supported Platforms

* Ubuntu Server 18.04 LTS

Ubuntu 20.04 LTS contains Python 3.8 by default, and the latest stable Apache Airflow is not compatible with 3.8 (yet).

## Usage

## `default` recipe

Installs the [GSW Data Transloader][data-transloader], scripts to automate the ETL, and Apache Airflow for managing the ETL jobs (as DAGs). Attributes are used to specify which stations to import for each data provider, as well as versions of software.

### Requirements

The recipe requires a Chef vault item. See the "Chef Vault" section below for more details.

This recipe requires a PostgreSQL user and database be **pre-configured** in your database, likely Amazon RDS. The connection details are stored in a Chef vault item (`database_url`).

```
postgres=> CREATE ROLE airflow WITH CREATEDB LOGIN PASSWORD '';
postgres=> CREATE DATABASE airflow;
postgres=> ALTER DATABASE airflow OWNER TO airflow;
```

**Recommendations:** Before bootstrapping a compute node with this cookbook and a connection to Chef Server, I recommend setting up a mounted volume for storing cached station observations and metadata and logs. These are stored in the following cookbook attributes:

* `default["etl"]["cache_dir"]`
* `default["etl"]["log_dir"]`

For using the file-based storage for the ETL, I recommend 10 GB for storage at least; more for a larger number of stations. If using the PostgreSQL backend for the ETL instead, a mounted volume may not be necessary as only log data will be output by the ETL tool.

## `unpause` recipe

Will use the Airflow command line interface to iteratively unpause all the DAGs found in the DAGs directory. This is kind of slow, so only run it when you need it.

## Attributes

See `attributes/default.rb` for documentation on available attributes in this cookbook.

## Chef Vault

The following Chef Vault items are required for the recipes in this cookbook. Note the different keys for different vault items (`asw-airflow-1` vs `asw-etl-1`).

The names of the Vault items can be overridden in the attributes, under the `node["transloader"]["airflow_vault"]` and `node["transloader"]["etl_vault"]` keys.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>secrets/asw-airflow-1['id']</tt></td>
    <td>String</td>
    <td>Vault Item ID</td>
    <td><tt>asw-airflow-1</tt></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-airflow-1['username']</tt></td>
    <td>String</td>
    <td>HTTP Basic Username for accessing the Apache Airflow web interface through nginx</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-airflow-1['password']</tt></td>
    <td>String</td>
    <td>HTTP Basic Password for accessing the Apache Airflow web interface through nginx</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-airflow-1['database_url']</tt></td>
    <td>String</td>
    <td>Database connection string for Airflow's access to PostgreSQL on RDS. Uses [SQLAlchemy's database URL API](https://docs.sqlalchemy.org/en/13/core/engines.html), so a driver may be specified as well.</td>
    <td><tt>postgresql://USER:PASS@HOST:PORT/DATABASE</tt></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-etl-1['id']</tt></td>
    <td>String</td>
    <td>Vault Item ID</td>
    <td><tt>asw-etl-1</tt></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-etl-1['http_basic_enabled']</tt></td>
    <td>Boolean</td>
    <td>If enabled, HTTP Basic parameters from this vault will be used for connections to SensorThings API. This is necessary for upload access to some STA instances.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-etl-1['username']</tt></td>
    <td>String</td>
    <td>HTTP Basic Username for uploading to SensorThings API</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-etl-1['password']</tt></td>
    <td>String</td>
    <td>HTTP Basic Password for uploading to SensorThings API</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/asw-etl-1['x-api-key']</tt></td>
    <td>String</td>
    <td>"X-Api-Key" header value for uploading to SensorThings API. If an empty string is used, then this header will be omitted.</td>
    <td></td>
  </tr>
</table>

In the following example, a `secrets` vault is created/updated for an `asw-airflow-1` item. It is only decryptable by the `airflow-server-1` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.

```terminal
$ knife vault create secrets asw-airflow-1 -C "airflow-server-1" -A "jpbadger"
(Your $EDITOR then opens to manually edit the JSON representation)
```

(For local development usage in Test Kitchen, an unencrypted data bag in `test/fixtures/data_bags/secrets` is used instead.)

## Roadmap

This cookbook is currently intended for a single compute node to run Airflow scheduler + web UI + executors and the ETL tool. In the future, this may be separated to better scale the heavy part (executors) from the lighter parts (scheduler, web UI).

* Switch to newer version of Data Transloader (v0.8.0+)
  - This provides access to the Postgres data and metadata store, which allows multiple ETL processes to run simultaneously
* Move Data Transloader execution into Docker
  - This would reduce the work required to set up a Ruby interpreter, and the Airflow executors could take advantage of Docker operators instead of Bash operators

## License and Authors

James Badger (jpbadger@ucalgary.ca)
