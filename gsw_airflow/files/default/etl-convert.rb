#!/usr/bin/env ruby
require 'json'
require 'nokogiri'
require 'time'

if ARGV.length != 1
  puts "etl-convert: incorrect number of arguments"
  exit 1
end

timestamp = Time.parse(ARGV[0])

cache_file = "/opt/etl/data-#{timestamp.strftime("%Y%m%dT%H")}.cache"

NAMESPACES = {
  'gml' => 'http://www.opengis.net/gml',
  'om' => 'http://www.opengis.net/om/1.0',
  'po' => 'http://dms.ec.gc.ca/schema/point-observation/2.0',
  'xlink' => 'http://www.w3.org/1999/xlink'
}

xml = Nokogiri::XML(IO.read(cache_file))

# Pre-defined datastreams
datastreams = [
  {
    "name" => "stn_pres",
    "uom" => "hPa",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673826)",
    "Sensor@iot.id" => 2673826,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671209)",
    "ObservedProperty@iot.id" => 2671209,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673869)",
    "Datastream@iot.id" => 2673869
  },
  {
    "name" => "mslp",
    "uom" => "hPa",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673827)",
    "Sensor@iot.id" => 2673827,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671226)",
    "ObservedProperty@iot.id" => 2671226,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673870)",
    "Datastream@iot.id" => 2673870
  },
  {
    "name" => "pres_tend_amt_pst3hrs",
    "uom" => "hPa",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673828)",
    "Sensor@iot.id" => 2673828,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671224)",
    "ObservedProperty@iot.id" => 2671224,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673871)",
    "Datastream@iot.id" => 2673871
  },
  {
    "name" => "pres_tend_char_pst3hrs",
    "uom" => "code",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673829)",
    "Sensor@iot.id" => 2673829,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671222)",
    "ObservedProperty@iot.id" => 2671222,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673872)",
    "Datastream@iot.id" => 2673872
  },
  {
    "name" => "altmetr_setng",
    "uom" => "inHg",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673830)",
    "Sensor@iot.id" => 2673830,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673857)",
    "ObservedProperty@iot.id" => 2673857,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673873)",
    "Datastream@iot.id" => 2673873
  },
  {
    "name" => "air_temp",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673831)",
    "Sensor@iot.id" => 2673831,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671190)",
    "ObservedProperty@iot.id" => 2671190,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673874)",
    "Datastream@iot.id" => 2673874
  },
  {
    "name" => "dwpt_temp",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673832)",
    "Sensor@iot.id" => 2673832,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671225)",
    "ObservedProperty@iot.id" => 2671225,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673875)",
    "Datastream@iot.id" => 2673875
  },
  {
    "name" => "rel_hum",
    "uom" => "%",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673833)",
    "Sensor@iot.id" => 2673833,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671191)",
    "ObservedProperty@iot.id" => 2671191,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673876)",
    "Datastream@iot.id" => 2673876
  },
  {
    "name" => "max_air_temp_pst1hr",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673834)",
    "Sensor@iot.id" => 2673834,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671193)",
    "ObservedProperty@iot.id" => 2671193,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673877)",
    "Datastream@iot.id" => 2673877
  },
  {
    "name" => "min_air_temp_pst1hr",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673835)",
    "Sensor@iot.id" => 2673835,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671195)",
    "ObservedProperty@iot.id" => 2671195,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673878)",
    "Datastream@iot.id" => 2673878
  },
  {
    "name" => "max_air_temp_pst6hrs",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673836)",
    "Sensor@iot.id" => 2673836,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671217)",
    "ObservedProperty@iot.id" => 2671217,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673879)",
    "Datastream@iot.id" => 2673879
  },
  {
    "name" => "min_air_temp_pst6hrs",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673837)",
    "Sensor@iot.id" => 2673837,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671218)",
    "ObservedProperty@iot.id" => 2671218,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673880)",
    "Datastream@iot.id" => 2673880
  },
  {
    "name" => "max_air_temp_pst24hrs",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673838)",
    "Sensor@iot.id" => 2673838,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671221)",
    "ObservedProperty@iot.id" => 2671221,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673881)",
    "Datastream@iot.id" => 2673881
  },
  {
    "name" => "min_air_temp_pst24hrs",
    "uom" => "°C",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673839)",
    "Sensor@iot.id" => 2673839,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671223)",
    "ObservedProperty@iot.id" => 2671223,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673882)",
    "Datastream@iot.id" => 2673882
  },
  {
    "name" => "vis",
    "uom" => "km",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673840)",
    "Sensor@iot.id" => 2673840,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673858)",
    "ObservedProperty@iot.id" => 2673858,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673883)",
    "Datastream@iot.id" => 2673883
  },
  {
    "name" => "cld_amt_code_1",
    "uom" => "code",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673841)",
    "Sensor@iot.id" => 2673841,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673859)",
    "ObservedProperty@iot.id" => 2673859,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673884)",
    "Datastream@iot.id" => 2673884
  },
  {
    "name" => "cld_typ_1",
    "uom" => "code",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673842)",
    "Sensor@iot.id" => 2673842,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673860)",
    "ObservedProperty@iot.id" => 2673860,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673885)",
    "Datastream@iot.id" => 2673885
  },
  {
    "name" => "cld_bas_hgt_1",
    "uom" => "m",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673843)",
    "Sensor@iot.id" => 2673843,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673861)",
    "ObservedProperty@iot.id" => 2673861,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673886)",
    "Datastream@iot.id" => 2673886
  },
  {
    "name" => "vert_vis",
    "uom" => "m",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673844)",
    "Sensor@iot.id" => 2673844,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673862)",
    "ObservedProperty@iot.id" => 2673862,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673887)",
    "Datastream@iot.id" => 2673887
  },
  {
    "name" => "tot_cld_amt",
    "uom" => "%",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673845)",
    "Sensor@iot.id" => 2673845,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673863)",
    "ObservedProperty@iot.id" => 2673863,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673888)",
    "Datastream@iot.id" => 2673888
  },
  {
    "name" => "avg_wnd_dir_10m_pst2mts",
    "uom" => "°",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673846)",
    "Sensor@iot.id" => 2673846,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671207)",
    "ObservedProperty@iot.id" => 2671207,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673889)",
    "Datastream@iot.id" => 2673889
  },
  {
    "name" => "avg_wnd_spd_10m_pst2mts",
    "uom" => "km/h",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673847)",
    "Sensor@iot.id" => 2673847,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671206)",
    "ObservedProperty@iot.id" => 2671206,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673890)",
    "Datastream@iot.id" => 2673890
  },
  {
    "name" => "avg_wnd_dir_10m_pst10mts",
    "uom" => "°",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673848)",
    "Sensor@iot.id" => 2673848,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671198)",
    "ObservedProperty@iot.id" => 2671198,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673891)",
    "Datastream@iot.id" => 2673891
  },
  {
    "name" => "avg_wnd_spd_10m_pst10mts",
    "uom" => "km/h",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673849)",
    "Sensor@iot.id" => 2673849,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671197)",
    "ObservedProperty@iot.id" => 2671197,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673892)",
    "Datastream@iot.id" => 2673892
  },
  {
    "name" => "max_wnd_gst_spd_10m_pst10mts",
    "uom" => "km/h",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673850)",
    "Sensor@iot.id" => 2673850,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673864)",
    "ObservedProperty@iot.id" => 2673864,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673893)",
    "Datastream@iot.id" => 2673893
  },
  {
    "name" => "rnfl_snc_last_syno_hr",
    "uom" => "mm",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673851)",
    "Sensor@iot.id" => 2673851,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673865)",
    "ObservedProperty@iot.id" => 2673865,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673894)",
    "Datastream@iot.id" => 2673894
  },
  {
    "name" => "pcpn_amt_pst6hrs",
    "uom" => "mm",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673852)",
    "Sensor@iot.id" => 2673852,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671215)",
    "ObservedProperty@iot.id" => 2671215,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673895)",
    "Datastream@iot.id" => 2673895
  },
  {
    "name" => "pcpn_amt_pst24hrs",
    "uom" => "mm",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673853)",
    "Sensor@iot.id" => 2673853,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2671220)",
    "ObservedProperty@iot.id" => 2671220,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673896)",
    "Datastream@iot.id" => 2673896
  },
  {
    "name" => "snw_dpth",
    "uom" => "cm",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673854)",
    "Sensor@iot.id" => 2673854,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673866)",
    "ObservedProperty@iot.id" => 2673866,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673897)",
    "Datastream@iot.id" => 2673897
  },
  {
    "name" => "rmk",
    "uom" => "unitless",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673855)",
    "Sensor@iot.id" => 2673855,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673867)",
    "ObservedProperty@iot.id" => 2673867,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673898)",
    "Datastream@iot.id" => 2673898
  },
  {
    "name" => "prsnt_wx_1",
    "uom" => "code",
    "Sensor@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Sensors(2673856)",
    "Sensor@iot.id" => 2673856,
    "ObservedProperty@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/ObservedProperties(2673868)",
    "ObservedProperty@iot.id" => 2673868,
    "Datastream@iot.navigationLink" => "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Datastreams(2673899)",
    "Datastream@iot.id" => 2673899
  }
]

# Use #map to create array of Observation entities
observations = datastreams.map do |datastream|
  datastream_link = datastream["Datastream@iot.navigationLink"]
  datastream_name = datastream["name"]
  {
    "url" => "#{datastream_link}/Observations",
    "entity" => {
      "phenomenonTime" => xml.xpath('//om:samplingTime/gml:TimeInstant/gml:timePosition', NAMESPACES).text,
      "result" => xml.xpath("//om:result/po:elements/po:element[@name='#{datastream_name}']/@value", NAMESPACES).text,
      "resultTime" => xml.xpath('//om:resultTime/gml:TimeInstant/gml:timePosition', NAMESPACES).text
    }
  }
end

IO.write("/opt/etl/entities-#{timestamp.strftime("%Y%m%dT%H")}.json", JSON.pretty_generate(observations))
File.delete(cache_file)
