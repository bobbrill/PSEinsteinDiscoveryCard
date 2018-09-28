Note, this component is forked from thedges/PSEinsteinDiscoveryCard. Its purpose is to show the same data by calling the Scoring API directly. No "Writeback" required.

# PSEinsteinDiscoveryCard

This component is an enhancement some examples found in an SDO for showing Einstein Discovery results in a component on page. The original components found were "hard coded" to the object that stored the Einstein Discovery results. This component is fully generic and can be placed on any object and all parameters are configurable.

The following is example screenshot of the component showing the Einstein Discovery results in component on right-hand side.

![alt text](https://raw.githubusercontent.com/thedges/PSEinsteinDiscoveryCard/master/PSEinsteinDiscoveryCard.jpg "Sample Image")

### Pre-requisite

* Setup Einstein Discovery and deploy a Model as defined [here](https://help.salesforce.com/articleView?id=bi_edd_wb_deploy.htm&type=5)

### Custom color and logo

Latest version has configuration options (Card title color, Header logo, Header background image, Header background color) to configure the colors to your needs. Here is sample card:

<img src="https://raw.githubusercontent.com/thedges/PSEinsteinDiscoveryCard/master/CardCustom.gif" height="271" width="273">

### This component has the following configuration properties:

* <b>Prediction Definition ID</b> - ID of the PredictionDefinition to use for live scoring
* <b>Card title</b> - the title string of the card to be displayed at top
* <b>Card title color</b> - the text color for the title of the card to be displayed at top
* <b>Header logo</b> - the icon to show on right-side of header section; this should be relative URL to a static resource file; default is Einstein logo at "/resource/PSEinsteinImages/einstein_header_icon.svg"; if you use custom logo icon, suggest to adjust height to about 110px 
* <b>Header background image</b> - the background image of the header section; this should be relative URL to a static resource file; default is cloud image at "/resource/PSEinsteinImages/einstein_header_background.svg"
* <b>Header background color</b> - the background color of the header section (this will override the background image)
* <b>Label for outcome score</b> - the label string to display at right of outcome score
* <b>Unit of measure of outcome score</b> - the unit of measure for the outcome score
* <b>Space before unit of measure</b> - boolean flag to put a space before the unit of measure
* <b>Place unit before outcome value</b> - boolean flag to place unit before outcome value (ex: for $ values)
* <b>Color range definition for red,yellow,green</b> - a range of values to determine the color of the outcome score. The string is in format like "-100,0|0,0|0,100" where first range defines red, second yellow and third green.

* <b>Label for section 1</b> - the label to show at top of the first section of Einstein Discovery results
* <b>Empty msg for section 1</b> - the message to show if this data is empty
* <b>Section 1 color range </b> - a range of values to determine the color of the section 1 values. The string is in format like "0,25|25,75|75,100" where first range defines red, second yellow and third green.
* <b>Section 1 Scale</b> - number formatting - number of decimal places to show for the section 1 values.
* <b>Section 1 Limit</b> - limit of results to show in section 1. "other" and "baseline" are always included. We do not recommend setting this value as 'other' does not (currently) add in the cut values.

* <b>Label for section 2</b> - the label to show at top of the section section of Einstein Discovery results
* <b>Empty msg for section 2</b> - the message to show if this data is empty
* <b>Section 2 color range </b> - a range of values to determine the color of the section 2 values. The string is in format like "-100,0|0,0|0,100" where first range defines red, second yellow and third green.
* <b>Section 2 Scale</b> - Number formatting - number of decimal places to show for the section 2 values.
* <b>Section 2 Limit</b> - limit for results to show in section 2

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
