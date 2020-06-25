# Changelog for asw-etl

## v1.0.0

Split off from `blackfoot` cookbook that ran the original ETL process for bringing external sensor data into [OGC SensorThings API][STA]. This new cookbook will have a similar purpose, but will load into a new SensorThings API hosted by the [Arctic Institute of North America][AINA] (AINA) on Amazon Web Services.

* Removed included FROST Server; EC2 instances are used instead for scalability and monitoring
    - Test deployments in [test-kitchen][] will now use a public STA instance that occasionally resets itself
* Removed installation of PostgreSQL for Apache Airflow; Amazon RDS is used instead for enhanced monitoring
* Removed local installation of "munin-node"; Amazon CloudWatch will be used instead for keeping track of resource usage
* Removed install of Arctic Sensor Web Community Dashboard web UI; this will be installed on Amazon S3/CloudFront (or similar)
* *Temporarily* removed ingest of station data from Environment and Climate Change Canada weather stations

[AINA]: https://arctic.ucalgary.ca
[STA]: https://www.ogc.org/standards/sensorthings
[test-kitchen]: https://kitchen.ci
