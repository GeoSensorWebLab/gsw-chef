# `banff` Cookbook

Cookbook for setting up a node with web map generation services:

* Nginx reverse caching proxy
* Let's Encrypt certificates

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## gsw-cookbook-template

Include `banff` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[banff]"
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
    <td><tt>['banff']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
