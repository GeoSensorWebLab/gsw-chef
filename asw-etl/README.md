# `asw-etl` cookbook

Cookbook for setting up a node with Arctic Sensor Web ETL:

* Nginx
* GSW Data Transloader
* Apache Airflow for monitoring/scheduling Data Transloader

This cookbook is based on the `blackfoot` node cookbook. This node is intended to run on AWS EC2.

Arctic Sensor Web is a part of the [Arctic Connect platform](https://www.arcticconnect.ca).

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## `default` recipe

Installs the [GSW Data Transloader](https://github.com/GeoSensorWebLab/data-transloader/), scripts to automate the ETL, and Apache Airflow for managing the ETL jobs (as DAGs). Attributes are used to specify which stations to import for each data provider, as well as versions of software.

**Please Note:** The recipe requires a Chef vault item. See the "Chef Vault" section below for more details.

**Recommendations:** Before bootstrapping a compute node with this cookbook and a connection to Chef Server, I recommend setting up a mounted volume for storing cached station observations and metadata and logs. These are stored in the following cookbook attributes:

* `default["etl"]["cache_dir"]`
* `default["etl"]["log_dir"]`

For using the file-based storage for the ETL, I recommend 10 GB for storage at least; more for a larger number of stations. If using the PostgreSQL backend for the ETL instead, a mounted volume may not be necessary as only log data will be output by the ETL tool.

## `unpause` recipe

Will use the Airflow command line interface to iteratively unpause all the DAGs found in the DAGs directory. This is kind of slow, so only run it when you need it.

## Attributes

See `attributes/default.rb` for documentation on available attributes in this cookbook.

## Chef Vault

The following Chef Vault items are required for the recipes in this cookbook.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>secrets/airflow['id']</tt></td>
    <td>String</td>
    <td>Vault Item ID</td>
    <td><tt>airflow</tt></td>
  </tr>
  <tr>
    <td><tt>secrets/airflow['username']</tt></td>
    <td>String</td>
    <td>HTTP Basic Username for accessing the Apache Airflow web interface through nginx</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/airflow['password']</tt></td>
    <td>String</td>
    <td>HTTP Basic Password for accessing the Apache Airflow web interface through nginx</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/arctic_sensors['id']</tt></td>
    <td>String</td>
    <td>Vault Item ID</td>
    <td><tt>arctic_sensors</tt></td>
  </tr>
  <tr>
    <td><tt>secrets/arctic_sensors['http_basic_enabled']</tt></td>
    <td>Boolean</td>
    <td>If enabled, HTTP Basic parameters from this vault will be used for connections to SensorThings API. This is necessary for upload access to some STA instances.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/arctic_sensors['username']</tt></td>
    <td>String</td>
    <td>HTTP Basic Username for uploading to SensorThings API</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/arctic_sensors['password']</tt></td>
    <td>String</td>
    <td>HTTP Basic Password for uploading to SensorThings API</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/arctic_sensors['x-api-key']</tt></td>
    <td>String</td>
    <td>"X-Api-Key" header value for uploading to SensorThings API. If an empty string is used, then this header will be omitted.</td>
    <td></td>
  </tr>
</table>

In the following example, a `secrets` vault is created/updated for an `airflow` item, with a `password`. It is only decryptable by the `asw-etl` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.

```terminal
$ knife vault create secrets airflow '{"password": "mypassword"}' -C "asw-etl" -A "jpbadger"
```

(For local development usage in Test Kitchen, an unencrypted data bag in `test/fixtures/data_bags/secrets` is used instead.)

## License and Authors

James Badger (jpbadger@ucalgary.ca)
