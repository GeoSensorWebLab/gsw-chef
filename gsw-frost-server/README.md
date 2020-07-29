# GSW FROST Server

Installs FROST HTTP Server onto the node.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## gsw-frost-server

Include `gsw-frost-server` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gsw-frost-server]"
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
    <td><tt>['gsw-frost-server']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
