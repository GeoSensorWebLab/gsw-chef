#!/usr/bin/env ruby
require 'time'

if ARGV.length != 1
  puts "etl-download: incorrect number of arguments"
  exit 1
end

timestamp = Time.parse(ARGV[0])

cache_file = "/opt/etl/data-#{timestamp.strftime("%Y%m%dT%H")}.cache"
url = "http://dd.weather.gc.ca/observations/swob-ml/#{timestamp.strftime("%Y%m%d")}/CYYC/#{timestamp.strftime("%Y-%m-%d-%H")}00-CYYC-MAN-swob.xml"

# Switch to execution of curl
`curl -XGET "#{url}" -o "#{cache_file}"`

if $? != 0
  exit 1
end
