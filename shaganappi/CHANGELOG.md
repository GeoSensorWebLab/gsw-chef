# Changelog for shaganappi

## v0.3.0

* Fix bug where `postgres` user was used before being created by a PostgreSQL installation
* Add support for using Amazon S3 as a backup repository for `pgbackrest`
* Add attribute to toggle S3 backups on or off
* Update backup and restore guide for modified restoration from S3

## v0.2.0

* Automate setup of postgresql
* Set up empty databases and users for web apps, if none exist
* Add automated database backups using pgbackrest

## v0.1.0

* Initial release