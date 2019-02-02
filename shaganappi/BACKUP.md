# Automated Encrypted Database Backups

This cookbook will configure a server with an automated backup system for PostgreSQL: [pgbackrest](https://pgbackrest.org/).

Backups are:

* Automatically scheduled to minimize data loss
* Incremental to minimize size of backup archive
* Compressed to reduce backup archive size
* Encrypted so backups cannot be read without key
* Uploaded to S3 on a different cloud platform

pgbackrest is located in the Debian/Ubuntu repositories, and is well documented. It is specific to PostgreSQL, and that should make it more reliable than a `pg_dumpall` solution.

## How It Works

The backup program will make a dump of the postgres database, and use incremental backups to make additional archives with newer data. This allows us to run more backups more often without requiring significantly more storage space.

In-progress backups are stored in the "repository". This is located in the `/db-pool/pgbackrest` directory.

Configuration for pgbackrest is in the `/etc/pgbackrest.conf` file.

For more detailed information, please refer to the [pgbackrest User Guide](https://pgbackrest.org/user-guide.html).

## Validating Backups

Backups are uploaded to an S3 bucket for the GeoSensorWeb Lab. You can manually browse the bucket to the path `/pgbackrest/node.name/backup/main` to see the date of the latest backup.

On the backup node, the [pgbackrest command can check the backups too](https://pgbackrest.org/user-guide.html#quickstart/backup-info).

```terminal
$ sudo -u postgres pgbackrest info
```

## Restore Procedure

Also see: [pgbackrest user guide to restore backups](https://pgbackrest.org/user-guide.html#restore)

The first step is to edit the cron file to temporarily disable backups during the restore procedure. Remove the `/etc/cron.d/pgbackrest` file to disable automatic backups. (Re-run `chef-client` to restore the cron file after restoring the database.)

You must restore the same version of PostgreSQL as the backup. It isn't too difficult to manage multiple versions of Postgres on Debian/Ubuntu using `pg_lsclusters` and [its related commands](https://wiki.debian.org/PostgreSql). After restoring to the same version, you can upgrade or do a dump to a different version in a different cluster.

You may need to initialize a new pgbackrest configuration file with the S3 connection details, so that pgbackrest can connect and restore the database. Here is a sample config that could be used as a base:

```
[global]
# The decryption passphrase
repo1-cipher-pass=<%= @repo_cipher_pass %>
# The encryption cipher
repo1-cipher-type=aes-256-cbc
# The path in S3 for the backups
repo1-path=<%= @repo_path %>
repo1-retention-full=2
start-fast=y
stop-auto=y
# The S3 bucket name, NOT the ARN
repo1-s3-bucket=<%= @s3[:bucket] %>
# The domain for the S3 endpoint, must be specific to the
# correct region!
repo1-s3-endpoint=<%= @s3[:endpoint] %>
# host must be the same as the endpoint or else you will get
# TLS errors
repo1-s3-host=<%= @s3[:endpoint] %>
# AWS IAM Access Key ID that can read from the bucket
repo1-s3-key=<%= @s3[:access_key] %>
# AWS IAM Secret Key that can read from the bucket
repo1-s3-key-secret=<%= @s3[:secret_key] %>
# AWS S3 Region: default is 'us-east-1'
repo1-s3-region=<%= @s3[:region] %>
repo1-type=s3

# Default cluster is 'main'
[<%= cluster[:name] %>]
# The path where the database is stored on disk,
# use `pg_lsclusters` to find the default ones
db-path=<%= cluster[:dbpath] %>
```

The vaules for the [ERB](https://en.wikipedia.org/wiki/ERuby) tags are stored in an encrypted file, contact James Badger for that information.

It is probably possible to download the S3 directory to disk, and use a *local* pgbackrest repository to do the restore; I haven't tried it yet.

TODO: How to download/decrypt the backup and load the backup into a new or existing PostgreSQL database cluster

