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
              <sld:ColorMapEntry color="#8e9891" label="-394.7" quantity="-394.740478515625"/>
              <sld:ColorMapEntry color="#bccfc2" label="320" quantity="320.028591579861"/>
              <sld:ColorMapEntry color="#d3d7c5" label="1035" quantity="1034.79766167535"/>
              <sld:ColorMapEntry color="#e0cfbd" label="1750" quantity="1749.56673177083"/>
              <sld:ColorMapEntry color="#dcc2b4" label="2464" quantity="2464.33580186632"/>
              <sld:ColorMapEntry color="#d9cdc4" label="3179" quantity="3179.10487196181"/>
              <sld:ColorMapEntry color="#dad0ca" label="3894" quantity="3893.87394205729"/>
              <sld:ColorMapEntry color="#d8d1cd" label="4609" quantity="4608.64301215278"/>
              <sld:ColorMapEntry color="#dbdbdb" label="5323" quantity="5323.41208224826"/>
              <sld:ColorMapEntry color="#e6e6e6" label="6038" quantity="6038.18115234375"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
