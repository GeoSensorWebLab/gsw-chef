# GSW Cookbook Template

Template for building new Chef cookbooks.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## gsw-cookbook-template

Include `gsw-cookbook-template` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gsw-cookbook-template]"
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
    <td><tt>['gsw-cookbook-template']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
