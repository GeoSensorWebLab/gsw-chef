# `blackfoot` cookbook

Cookbook for setting up a node with Arctic Sensor Web Expanded services:

* Nginx
* GSW Data Transloader
* Apache Airflow for monitoring/scheduling Data Transloader
* FROST SensorThings API server (Optional)

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## blackfoot

Include `blackfoot` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[blackfoot]"
  ]
}
```

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
