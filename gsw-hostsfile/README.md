# `gsw-hostsfile` cookbook

Installs a customized hostsfile (`/etc/hosts`) on the node with aliases for nodes on the Cybera Rapid Access Cloud. These can be used for referring to nodes by name instead of by IP. The IPs can then be centrally managed in this cookbook when updated.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## gsw-cookbook-template

Include `gsw-hostsfile` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gsw-hostsfile]"
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
    <td><tt>['gsw-hostsfile']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
