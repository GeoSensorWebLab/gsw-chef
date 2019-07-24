# `stoney` cookbook

This cookbook sets up the `stoney` node as a reverse proxy server on the Cybera Rapid Access Cloud.

* hostsfile entries for other nodes
* nginx
* SSL certificates from Let's Encrypt

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## gsw-cookbook-template

Include `stoney` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[stoney]"
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
    <td><tt>['stoney']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
