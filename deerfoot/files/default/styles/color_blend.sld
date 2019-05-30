<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" version="1.0.0">
  <!--
    Based on tpushuf, modified for ArcticDEM 
    http://soliton.vm.bytemark.co.uk/pub/cpt-city/tp/tn/tpushuf.png.index.html
    Author: Tom Patterson, 2011
    Public Domain
  -->
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>DEM Color Blend</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry quantity="-249" color="#8e9891" label="-249"/>
              <sld:ColorMapEntry quantity="527.166666666667" color="#c6d2c3" label="527.2"/>
              <sld:ColorMapEntry quantity="1303.33333333333" color="#e0cfbd" label="1303"/>
              <sld:ColorMapEntry quantity="2079.5" color="#dbc6bb" label="2080"/>
              <sld:ColorMapEntry quantity="2855.66666666667" color="#dad0ca" label="2856"/>
              <sld:ColorMapEntry quantity="3631.83333333333" color="#d9d5d3" label="3632"/>
              <sld:ColorMapEntry quantity="4408" color="#e6e6e6" label="4408"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
        <VendorOption name="composite">multiply</VendorOption>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
