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

**Note**: Restoring directly from S3 seems to be broken (see [issue](https://github.com/pgbackrest/pgbackrest/issues/669)). Instead, we will download the archive from S3 to the local machine and do a local repository restore using pgbackrest. After the restore is confirmed to be working, backup to S3 can be re-enabled.

Create a new pgbackrest configuration file with the local repository location. Here is a sample config that could be used as a base:

```
[global]
# The decryption passphrase
repo1-cipher-pass=<%= @repo_cipher_pass %>
# The encryption cipher
repo1-cipher-type=aes-256-cbc
repo1-path=/db-pool/pgbackrest-s3/shaganappi-staging
repo1-retention-full=2
start-fast=y
stop-auto=y

# Default cluster is 'main'
[main]
# The path where the database is stored on disk,
# use `pg_lsclusters` to find the default ones
db-path=/db-pool/postgresql/11/main
```

(Contact James Badger for the cipher password.)

Next, create the `/db-pool/pgbackrest-s3` directory. From S3, download the `/pgbackrest/shaganappi-staging` directory into `/db-pool/pgbackrest-s3` — the name should match the node you want to restore from. If it is different, the configuration file must also be updated.

I recommend [using the S3 CLI to download from the bucket](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html).

Once downloaded, you get verify that pgbackrest can see the backup:

```terminal
$ sudo -u postgres pgbackrest info
stanza: main
    status: ok
    cipher: aes-256-cbc

    db (current)
        wal archive min/max (11-1): 000000010000000000000006 / 000000010000000000000007

        full backup: 20190207-213945F
            timestamp start/stop: 2019-02-07 21:39:45 / 2019-02-07 21:49:16
            wal start/stop: 000000010000000000000006 / 000000010000000000000006
            database size: 30.1MB, backup size: 30.1MB
            repository size: 3.6MB, repository backup size: 3.6MB
```

If there are errors, check the paths in your configuration file.

Next, shut down your local Postgres cluster.

```terminal
$ sudo pg_ctlcluster 11 main stop
```

If you are doing a FULL restore, then delete the contents of the PG data directory. If you are doing a DELTA restore, skip this step!

```terminal
$sudo -u postgres pgbackrest --log-level-console=info --stanza=main restore
```

If you want to do a smaller restore, or a point-in-time-recovery, see the [pgbackrest user guide](https://pgbackrest.org/user-guide.html#pitr).

The restore should work fairly quickly with the backup being on the local disk. Once done, try starting Postgres.

```terminal
$ sudo pg_ctlcluster 11 main start
```

If it starts without any errors, great! If not, check the log using `journalctl -xe` and see what went wrong.

If the restore worked, you can now re-enable the backup automation:

1. Update the pgbackrest configuration file to backup to S3
2. Delete the local copy of the S3 data in `/db-pool/pgbackrest-s3`
3. Try running a manual backup using `sudo -u postgres pgbackrest --stanza=main --log-level-console=info backup`
4. Restore the pgbackrest cron file by running `sudo chef-client`

