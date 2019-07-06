#!/usr/bin/env ruby
require 'json'
require 'time'

if ARGV.length != 1
  puts "etl-upload: incorrect number of arguments"
  exit 1
end

timestamp = Time.parse(ARGV[0])

entities_file = "/opt/etl/entities-#{timestamp.strftime("%Y%m%dT%H")}.json"

entities = JSON.parse(IO.read(entities_file))

results = entities.map do |observation|
  url = observation["url"]
  entity = observation["entity"]
  `curl -XPOST -H 'Content-Type: application/json' -d '#{JSON.generate(entity)}' '#{url}'`
  $?.exitstatus
end

File.delete(entities_file)

if results.any? { |code| code != 0 }
  puts "One or more requests failed"
  exit 1
end
