# Singapore Airbnb Map Visualization

Leaflet map [visualization](https://jwc225.shinyapps.io/airbnb_singapore_viz/) of Airbnb listings in Singapore available on 26 October 2020. Listing data accquired from http://insideairbnb.com/.

![Image: A capture of the leaflet visualization. Dated 9 Dec 2020.](https://github.com/jwc225/airbnb-singapore-visualization/blob/b237f58cece53a52dd838f6e500e4a9d0250d46b/img/web-app-capture.jpg)

## Work in Progress / Possible Future Plans

* add new cities and listing data to visualize
  * create select menu for user to choose city
  
* <del>add an optional price marker map layer that can be turned on/off to quickly see prices</del>
  update: This option increases drastically increases loadtimes. Unfeasible unless functionality is added to
          prevent all listing labels to be shown at once (show only a limited number of listings, within the current zoom range). 

* add filter options for ameneities

* add widget to filter by number of reviews

* add a section that includes summary information of map filtered listings

* add other visualizations (scatters, bargraphs, new maps) in separate tab panels

## Completed

* Hover label on map listings that shows price/night
