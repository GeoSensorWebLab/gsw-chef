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

**Please Note:** The recipe requires a Chef vault item. In the following example, a `secrets` vault is created/updated for an `airflow` item, with a `password`. It is only decryptable by the `blackfoot` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.


```terminal
$ knife vault create secrets airflow '{"password": "mypassword"}' -C "blackfoot" -A "jpbadger"
```

(For local development usage in Test Kitchen, an unencrypted data bag in `test/fixtures/data_bags/secrets` is used instead.)

## `frost` recipe

Install FROST SensorThings API server using Docker. This instance can then be used locally with the GSW Data Transloader instead of pushing to a public STA instance.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['blackfoot']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
