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

Uploading this cookbook to Chef Server:

```terminal
$ berks vendor ../berks-cookbooks
$ bundle exec knife cookbook upload . -ad -o ../berks-cookbooks
...
$ knife cookbook list
...
crowchild    0.1.0
```

### crowchild

Include `crowchild` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[crowchild]"
  ]
}
```

The recipe requires a Chef vault item. In the following example, a `secrets` vault is created/updated for an `icinga` item, with a `db_password`. It is only decryptable by the `crowchild` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.


```terminal
$ knife vault create secrets icinga '{"db_password": "mypassword"}' -C "crowchild" -A "jpbadger"
```

### Attributes

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

## Test Kitchen Tips

If you have a local apt-cacher-ng server, you can use the [vagrant-proxyconf](http://tmatilai.github.io/vagrant-proxyconf/) plugin. Set the `VAGRANT_APT_HTTP_PROXY` environment variable before creating your test kitchen instances:

```terminal
$ export VAGRANT_APT_HTTP_PROXY="http://192.168.1.33:3142"
$ kitchen create
```

Using apt-cacher-ng will speed up package downloads if you are re-creating VM instances.

## License and Authors

James Badger (jpbadger@ucalgary.ca)
