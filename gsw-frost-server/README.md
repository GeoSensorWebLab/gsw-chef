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
  <tr>
    <td><tt>['frost_server']['env']</tt></td>
    <td>Hash</td>
    <td>A key-value list (both Strings) of Environment Variables that will be sent to the FROST Server Docker container.</td>
    <td><tt>See attributes/default.rb</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
