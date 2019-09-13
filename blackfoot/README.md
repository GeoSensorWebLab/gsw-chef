# `blackfoot` cookbook

Cookbook for setting up a node with Arctic Sensor Web Expanded services:

* Nginx
* GSW Data Transloader
* Apache Airflow for monitoring/scheduling Data Transloader
* FROST SensorThings API server (Optional)

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## `default` recipe

Installs the GSW Data Transloader, scripts to automate the ETL, and Apache Airflow for managing the ETL jobs (as DAGs). Attributes are used to specify which stations to import for each data provider, as well as versions of software.

DAGs for importing historical data from Data Garrison and Campbell Scientific will also be installed, and by default will import from 2016-01-01 (configurable via attributes) to the current date. The GSW Data Transloader does not yet support downloading historical SWOB-ML data from Environment Canada (they only keep the last month of data available).

**Please Note:** The recipe requires a Chef vault item. See the "Chef Vault" section below for more details.

## `frost` recipe

Install FROST SensorThings API server using Docker. This instance can then be used locally with the GSW Data Transloader instead of pushing to a public STA instance.

## Attributes

See `attributes/default.rb` and `attributes/frost.rb` for documentation on available attributes in this cookbook.

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
    <td>HTTP Basic Username</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>secrets/airflow['password']</tt></td>
    <td>String</td>
    <td>HTTP Basic Password</td>
    <td></td>
  </tr>
</table>

In the following example, a `secrets` vault is created/updated for an `airflow` item, with a `password`. It is only decryptable by the `blackfoot` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.

```terminal
$ knife vault create secrets airflow '{"password": "mypassword"}' -C "blackfoot" -A "jpbadger"
```

(For local development usage in Test Kitchen, an unencrypted data bag in `test/fixtures/data_bags/secrets` is used instead.)

## License and Authors

James Badger (jpbadger@ucalgary.ca)
