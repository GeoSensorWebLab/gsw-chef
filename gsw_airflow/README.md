# `airflow` cookbook

Cookbook for setting up a node with an Apache Airflow demo.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## airflow

Include `airflow` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[airflow]"
  ]
}
```

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['airflow']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
