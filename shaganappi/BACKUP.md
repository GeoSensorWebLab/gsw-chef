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

TODO: Explain how to check that backups are being made, and how to download/decrypt them to see if they can be restored

## Restore Procedure

TODO: How to download/decrypt the backup and load the backup into a new or existing PostgreSQL database cluster

