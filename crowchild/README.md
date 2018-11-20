# `crowchild` cookbook

Cookbook for setting up a node with monitoring services:

* Icinga 2
* Icinga 2 Web
* Munin
* Munin Node
* HTTPS certificate from Let's Encrypt
    * domain: monitoring.arcticconnect.ca
    * domain: monitoring.gswlab.ca

Services monitored by Icinga 2 and Munin will be hard-coded in the attributes file for this cookbook. Eventually these will be auto-configured from other node's cookbooks using attributes or data bags managed by a Chef Server.

This server will be accessible by GSW Lab members and partners for checking service availability and potential system issues. It will be available from both the "arcticconnect.ca" domain and the "gswlab.ca" domain; each domain is managed separately by different registrars.

TODO: Log collector, searching

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## crowchild

Include `crowchild` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[crowchild]"
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
    <td><tt>['crowchild']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
