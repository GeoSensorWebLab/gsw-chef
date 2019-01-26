# `shaganappi` cookbook

Cookbook for setting up a node with a database server that can be accessed by multiple other nodes.

* PostgreSQL 11
* PostGIS
* Databases
* Database users
* Automated encrypted backups (see [BACKUP.md](BACKUP.md))
* WIP: Upload backups to Amazon S3
* WIP: Local-only NTP service for clock synchronization
* WIP: Munin Node results pushed to Munin primary server
* WIP: Icinga 2 results pushed to Icinga primary server

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
shaganappi    0.2.0
```

Below is a quick set of commands for bootstrapping a node with this cookbook, using Chef Server. See the section below for more details on the vault items.

```terminal
$ knife vault create apps geocens -S "*:*" -C "shaganappi" -A "jpbadger"
$ knife vault create secrets pgbackrest -S "*:*" -C "shaganappi" -A "jpbadger"
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

### Chef Vault

The recipe requires Chef vault items.

#### `apps`

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

In the following example, `apps` vault is created/updated for a `geocens` item. This will open an editor that must use the JSON schema above. It is only decryptable by the `shaganappi` client node OR by an admin named `jpbadger`. The client node and admin user would be defined in the Chef server.


```terminal
$ knife vault create apps geocens -C "shaganappi" -A "jpbadger"
```

#### `secrets`

Example:

```json
{
  "id": "pgbackrest",
  "cipher_pass": "mypassword"
}
```

```terminal
$ knife vault create secrets pgbackrest -C "shaganappi" -A "jpbadger"
```

## Developer Notes

For future cookbook editors/developers: be careful upgrading the PostgreSQL version as there is no automated cluster upgrade code in this cookbook. Also be sure to make sure it works with pgbackrest backup and restore.

## License and Authors

James Badger (jpbadger@ucalgary.ca)
