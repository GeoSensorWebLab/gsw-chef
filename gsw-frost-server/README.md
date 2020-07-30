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

The environment variables used to customize FROST Server must be specified in a [Chef Vault](https://github.com/chef/chef-vault) item. The recipe will look for a vault with a name from `node['frost_server']['frost_env_vault']` with an item with a name from `node['frost_server']['frost_env_item']`. This will then be decrypted and must have the following format:

```json
{
  "id": "vault_item",
  "env": {
    "http_cors_enable": "true",
    …
  }
}
```

The `env` object is then passed to Docker when starting FROST Server in a container.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['frost_server']['deploy_postgis']</tt></td>
    <td>Boolean</td>
    <td>If true, then PostGIS will be started in a Docker container and made available to the FROST Server container. The ENV still needs to be updated to refer to this container.</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['frost_server']['docker_repo']</tt></td>
    <td>String</td>
    <td>The Docker Hub repository for the combined FROST HTTP+MQTT Server.</td>
    <td><tt>fraunhoferiosb/frost-server</tt></td>
  </tr>
  <tr>
    <td><tt>['frost_server']['docker_tag']</tt></td>
    <td>String</td>
    <td>The Docker Hub repository for the combined FROST HTTP+MQTT Server will use this tag.</td>
    <td><tt>latest</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
