# `shaganappi` cookbook

Cookbook for setting up a node with a database server that can be accessed by multiple other nodes.

* PostgreSQL 11
* PostGIS
* Databases
* Database users
* Automated encrypted backups to Amazon S3
* Local-only NTP service for clock synchronization
* Munin Node results pushed to Munin primary server
* Icinga 2 results pushed to Icinga primary server

Databases and users will be created from encrypted Chef Data Bags stored on the Chef Server. If the database and/or user already exists, a new one will not be created.

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
shaganappi    0.1.0
```

Bootstrapping a node with this cookbook, using Chef Server:

```terminal
$ knife bootstrap shaganappi -N shaganappi \
  --ssh-user ubuntu --sudo --run-list 'recipe[shaganappi]'
```

### gsw-cookbook-template

Include `shaganappi` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[shaganappi]"
  ]
}
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
    <td><tt>['shaganappi']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

### Data Bags

* `apps`

Example:

```json
{
  "id": "geocens",
  "enabled": true,
  "database": {
    "type": "postgresql",
    "database_name": "geocens_production",
    "user": "geocens_user",
    "password": "geocens_password"
  }
}
```

## License and Authors

James Badger (jpbadger@ucalgary.ca)
