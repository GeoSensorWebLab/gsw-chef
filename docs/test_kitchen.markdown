# Test Kitchen Tips

Test Kitchen is a tool for setting up a local virtual machine that you can deploy this cookbook for testing. TK supports multiple "drivers", but the main ones are Vagrant with VirtualBox. Here are a few optimizations that should be used in `.kitchen.yml` depending on your development hardware/OS.

## Customize VM Options

Adjust these based on your available hardware. These values are based on [VirtualBox][VirtualBox Config].

```yaml
driver:
  name: vagrant
  customize:
    cpus: 4
    memory: 8192
    storagectl:
      - name: "SATA Controller"
        hostiocache: "off"
```

Disabling the Host I/O cache in VirtualBox noticeably increases disk sequential and random read/write speeds.

[VirtualBox Config]: https://www.vagrantup.com/docs/virtualbox/configuration.html

## Caching Apt Packages

If you have a local apt-cacher-ng server, you can use the [vagrant-proxyconf](http://tmatilai.github.io/vagrant-proxyconf/) plugin. Set the `VAGRANT_APT_HTTP_PROXY` environment variable before creating your test kitchen instances:

```terminal
$ export VAGRANT_APT_HTTP_PROXY="http://192.168.1.33:3142"
$ kitchen create
```

Using apt-cacher-ng will speed up package downloads if you are re-creating VM instances.

## Use Fixed VirtualBox Disk Images

`maps_server` includes a custom Vagrantfile (`Vagrant_fixed_disks.rb`) that will use the [Vagrant Disksize plugin][] to resize the base box image to 64 GB **and** use fixed allocation, courtesy of a monkey patch.

Fixed allocation disks offer a 2-3 times improvement in sequential write speeds, which is pretty important for a database driven cookbook.

[Vagrant Disksize plugin]: https://github.com/sprotheroe/vagrant-disksize

## Set a Synced Cache Directory

Store downloaded data on the HOST machine so they don't have to be re-downloaded. First example below is for MacOS, second is for Linux.

```yaml
driver:
  synced_folders:
    - ["/Users/YOU/Library/Caches/vagrant/%{instance_name}", "/srv/data", "create: true, type: :rsync"]
    - ["/home/YOU/data/vagrant/%{instance_name}", "/srv/data", "create: true, type: :rsync"]
```

These use the [RSync synced folders][RSync Synced Folders] instead of VirtualBox/NFS/SMB as the latter have a performance penalty which will slow down imports of PBF extracts. As the RSync method has to copy the files into the VM, it will be a bit slower to create the VM using `kitchen create`.

To sync updated shared folders back to the cache directory on the host, use the [vagrant-rsync-back][] plugin. Note that syncing to and from the VM uses the rsync `--delete` argument, so the destination will be cleaned to match the source.

[RSync Synced Folders]: https://www.vagrantup.com/docs/synced-folders/rsync.html
[vagrant-rsync-back]:https://github.com/smerrill/vagrant-rsync-back
