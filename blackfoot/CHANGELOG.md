# Changelog for blackfoot

## v1.0.0

* Fix port redirect issue when accessing Airflow
* Catch errors when ETL fails to download/upload data
* Handle alternate data interval for Data Garrison stations
* Speed up deployments by only rebuilding dashboard when it has been updated and not on every Chef client run
* Send Munin results to `crowchild` node
* Store Airflow logs on ZFS volume with compression
* Install an Airflow DAG for cleaning up old Airflow logs
* Collect ETL statistics using Munin for monitoring download/upload throughput
* Upgrade cookbook to use Ruby 2.7.0

## v0.2.0

* Install GSW Data Transloader from source on GitHub
* Deploy Apache Airflow
* Install PostgreSQL for Airflow database
* Add recipe for optionally installing FROST SensorThings API server
* Create separate Airflow DAGs for each station to import
* Create separate Airflow DAGs for historical data import on Data Garrison and Campbell Scientific
* Install Ruby from source for the Data Transloader
* Install Node from source for the Dashboard
* Deploy the Dashboard from source on GitHub

## v0.1.0

* Initial Version
