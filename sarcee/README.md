# Sarcee Node Cookbook

Sets up a node with:

* Dokku
* Docker
* Nginx
* Custom EOL static pages for GSW Lab
* Automatic Docker cleanup scripts

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## sarcee

Include `sarcee` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[sarcee]"
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
    <td><tt>['sarcee']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
