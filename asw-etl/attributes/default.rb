########################
# Cookbook Configuration
########################
default["transloader"]["repository"]   = "https://github.com/GeoSensorWebLab/data-transloader"
default["transloader"]["revision"]     = "v0.7.0"
default["transloader"]["install_home"] = "/opt/data-transloader"
default["transloader"]["user_home"]    = "/home/transloader"
default["transloader"]["user"]         = "transloader"

####################
# Ruby Configuration
####################
default["ruby"]["version"] = "2.6.6"

###################
# ETL Configuration
###################
# Start date for importing historical data using Airflow DAGs
default["etl"]["year"]  = 2016
default["etl"]["month"] = 1
default["etl"]["day"]   = 1
default["etl"]["cache_dir"] = "/srv/data"
default["etl"]["log_dir"]   = "/srv/logs"

################
# Apache Airflow
################
# Installation directory for Airflow
default["airflow"]["home"] = "/opt/airflow"
# Base URL for Airflow interface
default["airflow"]["base_url"] = "https://asw-etl.gswlab.ca"
# If false, will automatically enable all DAGs when added to scheduler
default["airflow"]["dags_are_paused_at_creation"] = true
# Limit number of DAGs that can run at the same time
default["airflow"]["parallelism"] = 1
# Limit the number of runs of the *same* DAG that can happen at the same
# time
default["airflow"]["dag_concurrency"] = 1
# Limits the number of runs of a DAG that can be in an active state
default["airflow"]["max_active_runs_per_dag"] = 1

#############################
# Environment Canada Stations
#############################
# Remember to use the four-letter codes; check the following CSV file:
# http://dd.weather.gc.ca/observations/doc/swob-xml_station_list.csv
default["transloader"]["environment_canada_stations"] = []

########################
# Data Garrison Stations
########################
default["transloader"]["data_garrison_stations"] = [
  {
    "name"       => "30 Mile Weather Station",
    "user_id"    => 300234063581640,
    "station_id" => 300234065673960,
    "latitude"   => 69.1580,
    "longitude"  => -107.0403,
    "timezone_offset" => "-06:00"
  },
  {
    "name"       => "Melbourne Island Weather Station",
    "user_id"    => 300234063581640,
    "station_id" => 300234063588720,
    "latitude"   => 68.5948,
    "longitude"  => -104.9363,
    "timezone_offset" => "-06:00"
  }
]

##############################
# Campbell Scientific Stations
##############################
default["transloader"]["campbell_scientific_stations"] = [
  {
    "name"            => "Qikirtaarjuk Island Weather Station",
    "station_id"      => 606830,
    "latitude"        => 68.983639,
    "longitude"       => -105.835833,
    "timezone_offset" => "-06:00",
    # From: http://dataservices.campbellsci.ca/sbd/606830/data/
    "data_files" => [
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR.dat"
    ],
    # Data files that will be used for a historical import DAG, *not*
    # for the regularly scheduled DAG.
    "archive_data_files" => [
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-23%2009-05-25.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-23%2019-05-24.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-23%2019-15-21.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-25%2022-20-26.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-25%2022-25-22.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-25%2022-30-24.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-04-30%2021-05-27.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-05-02%2008-05-58.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-05-05%2018-05-26.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-05-09%2003-05-18.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-05-12%2015-05-26.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-07-29%2013-05-33.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-08-08%2018-05-39.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2016-08-08%2022-05-39.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-04-26%2011-06-15.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-04-26%2012-06-44.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-04-28%2012-06-30.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-04-30%2016-06-09.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-05-01%2019-06-35.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-05-02%2015-07-10.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2017-05-02%2017-07-45.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-04-12%2016-04-34.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-04-14%2013-04-31.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-04-14%2014-04-31.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-04-14%2015-04-10.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-05-24%2007-32-25.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-08-05%2012-04-09.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2018-08-05%2015-04-05.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2019-05-05%2013-03-55.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2019-05-06%2013-03-55.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2019-05-06%2014-03-56.dat",
      "http://dataservices.campbellsci.ca/sbd/606830/data/CBAY_MET_1HR-Archive_2019-08-09%2011-03-53.dat"
    ]
  }
]

# Block these properties from being uploaded.
# This is passed directly into the `--blocked` argument in the data
# transloader command line tool.
default["transloader"]["campbell_scientific_blocked"] = "LdnCo_Avg,Ux_Avg,Uy_Avg,Uz_Avg,CO2_op_Avg,H2O_op_Avg,Pfast_cp_Avg,xco2_cp_Avg,xh2o_cp_Avg,mfc_Avg"

# Destination URL for uploading to SensorThings API. Include any path
# components up to the complete root URL (e.g. "/v1.0/") with a trailing
# slash.
default["sensorthings"]["external_uri"] = "https://arctic-sta.gswlab.ca/FROST-Server/v1.0/"
