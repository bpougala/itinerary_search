# itinerary_search
Quickly compute an itinerary from current position to any UK address

This simple iOS app allows the user to compute and visualise a route from their current position to any UK address. It uses a mixture of services from Mapbox, Bing Maps and Foursquare.

## How it works

<p align="center">
    <img width=235 height=500 src="https://gocab-taxis.eu/screenshot_1.png">
</p>

When the user opens the app, a map centered on their current location appears (here Warrington, Lancashire). Two buttons can be used: the search bar triggers a segue to another view controller and the white "target" button re-centers the map to the current position of the user. 

<p align="center">
    <img with=235 height=500 src="https://gocab-taxis.eu/screenshot_2.png">
    <img with=235 height=500 src="https://gocab-taxis.eu/screenshot_4.png">
</p>

When the user enters a query, some relevant suggestions appear listed, coming from either the Bing Maps API or the Foursquare API. These APIs aren't called directly from the app, but instead my backend server gets called with the user query. The PHP service then determines if the query is likely a venue, e.g. if it includes the name of a hotel chain (Holiday Inn, Novotel...), in which case the Foursquare API gets called, or the Bing Maps API in all other cases. Then the PHP service does some further preprocessing of the JSON results before sending them back to the app. This step is done to make it easier and quicker for the app (either iOS for now and eventually Android) to fill up the tableview, such as removing singleton and repetetive elements. 

<p align="center">
    <img width=235 height=500 src="https://gocab-taxis.eu/screenshot_5.jpg">
</p>

FInally, once the user has selected a query, the route from their position to the selected address is drawn on the map and an ETA (using a car and with the current traffic conditions) and distance - in meters, but a later version will add the distance in miles - get displayed.
