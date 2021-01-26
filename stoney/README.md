# `stoney` cookbook

This cookbook sets up the `stoney` node as a reverse proxy server on the Cybera Rapid Access Cloud.

* hostsfile entries for other nodes
* nginx
* HTTPS certificates from Let's Encrypt

TODO:

* Set up auto-renewals using `certbot`

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## `stoney::default` recipe

Include `stoney` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[stoney]"
  ]
}
```

### `acme_server` recipe

This recipe is for testing locally only with Test Kitchen. The recipe will install Docker and set up a container running [`pebble`][1]. Do not use this in production!

[1]: https://github.com/letsencrypt/pebble

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts']</tt></td>
    <td>Array</td>
    <td>Array of virtualhost hash objects.</td>
    <td>Defaults to standard virtual hosts.</td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]</tt></td>
    <td>Hash</td>
    <td>Definitions for an nginx virtual host.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['id']</tt></td>
    <td>String</td>
    <td>Name of the site, used for configuration filename.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['domains']</tt></td>
    <td>Array of Strings</td>
    <td>Domains for <tt>server_name</tt>.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['hsts_enabled']</tt></td>
    <td>Boolean</td>
    <td>If enabled, then Nginx will enable HTTP Strict Transport Security headers for the HTTP and HTTPS proxy configurations. Used to instruct browsers to use HTTPS.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['ssl_enabled']</tt></td>
    <td>Boolean</td>
    <td>If enabled, then certbot will be used to get certificates for each domain from Let's Encrypt.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['proxy_host']</tt></td>
    <td>String</td>
    <td>The hostname or IP address of the real service host.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['stoney']['vhosts'][]['proxy_port']</tt></td>
    <td>String</td>
    <td>The port of the service on its real host.</td>
    <td></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
