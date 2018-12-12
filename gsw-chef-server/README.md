# Chef Server

A Chef Server is an easy way to centrally manage the cookbooks, node attributes and run lists, and data bags. It is faster to deploy updates using a Chef Server instead of Chef Zero (bootstrap). Additionally it means configuration isn't limited to a single developer's machine, and that data bags won't need to be re-configured when setting up Chef Zero multiple times.

## Dependencies

This cookbook primarily depends on the following cookbooks.

* [chef-server-with-letsencrypt](https://gitlab.com/virtkick/chef-server-with-letsencrypt)
* [chef-server](https://supermarket.chef.io/cookbooks/chef-server)

Please see those cookbook pages for details on attributes as some are overridden in this cookbooks attributes file (`attributes/default.rb`).

## Installing Chef Server

For this lab the hardware requirements are very modest. A small amount of RAM and CPUs is okay as the server won't be doing too much most of the time. It is a good idea to start with a fresh OS install, and I will be using Ubuntu Server 18.04 LTS.

I have attached a 50 GB volume to the instance as the boot volume is only 5 GB and that won't be large enough for storing the Chef cookbooks. The command log below include formatting that volume.

### DNS

I updated the Amazon Web Service Route53 configuration to have a domain for this service:

```
chef.gswlab.ca A 162.246.156.221
barlow.gswlab.ca A 162.246.156.221
```

### Preconfiguration

```terminal
$ sudo apt update
$ sudo apt upgrade
$ sudo apt autoremove
$ sudo reboot
...

$ sudo parted -l
Error: /dev/sdb: unrecognised disk label
Model: QEMU QEMU HARDDISK (scsi)                                          
Disk /dev/sdb: 53.7GB
Sector size (logical/physical): 512B/512B
Partition Table: unknown
Disk Flags:

$ sudo parted /dev/sdb mklabel gpt
$ sudo parted /dev/sdb mkpart primary ext4 2048s 100%
(starting at 2048s avoids partition alignment warning)

$ sudo mkfs.ext4 /dev/sdb1
$ sudo mount /dev/sdb1 /opt
(The UUIDs for the partition are then added to /etc/fstab, so it auto-mounts)
$ sudo reboot

$ df -H
/dev/sdb1        53G   55M   50G   1% /opt
```

### Bootstrap

```terminal
$ berks install
$ berks vendor /tmp/berkshelf/cookbooks
$ /usr/local/bin/knife zero bootstrap barlow \
    --node-name barlow --local-mode --overwrite \
    --run-list 'recipe[gsw-chef-server]' --ssh-user ubuntu \
    --sudo --config ~/.chef/knife-zero.rb
```

### Post-Bootstrap: Admin User Configuration

```terminal
$ sudo chef-server-ctl user-create jpbadger James Badger jamesbadger@gmail.com 'PASSWORD' --filename jpbadger.pem
(I save my password and private key in a password manager)

$ sudo chef-server-ctl org-create gswlab 'GeoSensorWeb Lab' --association_user jpbadger --filename gswlab-validator.pem
```

The `jpbadger.pem` and `gswlab-validator.pem` files are installed on my development machine in the `~/.chef` directory.

### Knife config.rb

Each developer must set up their own `config.rb` file. This configuration file tells *Knife* how to access the Chef Server.

```ruby
current_dir = File.dirname(__FILE__)
user = ENV['OPSCODE_USER'] || ENV['USER']
node_name                user
client_key               "#{ENV['HOME']}/.chef/#{user}.pem"
validation_client_name   "gswlab-validator"
validation_key           "#{ENV['HOME']}/.chef/gswlab-validator.pem"
chef_server_url          "https://chef.gswlab.ca/organizations/gswlab"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntax_check_cache"
cookbook_copyright       "GeoSensorWeb Lab"
cookbook_license         "Apache-2.0"
cookbook_email           "jpbadger@ucalgary.ca"
```

### References

* https://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/

## Backup and Restore

[Chef: Backup and Restore a Standalone or Frontend install](https://docs.chef.io/server_backup_restore.html)

TODO: I will be setting it up to backup automatically on a schedule to Amazon S3 or similar.

## License and Authors

James Badger (jpbadger@ucalgary.ca)
