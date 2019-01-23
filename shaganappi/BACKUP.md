# Automated Encrypted Database Backups

This cookbook will configure a server with an automated backup system for PostgreSQL: [pgbackrest](https://pgbackrest.org/).

Backups are:

* Automatically scheduled to minimize data loss
* Incremental to minimize size of backup archive
* Compressed to reduce backup archive size
* Encrypted using GPG so only public keys are kept on server
* Uploaded to S3 on a different cloud platform

## How It Works

TODO: Explain how pgbackrest works, in short

For more detailed information, please refer to the [pgbackrest User Guide](https://pgbackrest.org/user-guide.html).

## Validating Backups

TODO: Explain how to check that backups are being made, and how to download/decrypt them to see if they can be restored

## Restore Procedure

TODO: How to download/decrypt the backup and load the backup into a new or existing PostgreSQL database cluster

