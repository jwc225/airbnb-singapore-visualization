# Load packages
library("shiny")
library("tidyverse")
library("leaflet")
library("RColorBrewer")
library("batman")

# Read data (set wdir to root)
data_sing <- read.csv("data/singapore_listings.csv", encoding="latin1")




# Define a server for the application
server <- function(input, output, session) {

  ##### Interactive Page One ##################################################

  # Change max price range when button clicked
  observeEvent(input$button, {
    max <- input$textbox
    updateSliderInput(session, "price_slider", max = max)
    updateTextInput(session, "textbox", value = "") # clear input after click
  })

  # Construct a color palette (scale) based on the `room-type` column
  palette_fn <- colorFactor(palette = "Dark2", domain = data_sing$room_type)

  # Replace price column with a vector of numbers
  data_sing$price <- as.numeric(gsub("[$,]", "", data_sing$price))

  # Replace superhost column with boolean values
  data_sing$host_is_superhost <- to_logical(data_sing$host_is_superhost)
  
  
  # Render leaflet map
  output$m_sing <- renderLeaflet({
  
    # change score ratings to a 5 point scale
    data_sing$review_scores_rating <- data_sing$review_scores_rating * 0.05  
    
    # Set listings with no reviews to 0 (assume default stars is zero)
    data_sing$review_scores_rating <- ifelse(data_sing$number_of_reviews == 0,
                                             0,
                                             data_sing$review_scores_rating) 
  
    # Dynamic user filtering
    plot_data <- data_sing %>%
      filter(review_scores_rating >= input$score_slider[1] &
               review_scores_rating <= input$score_slider[2]) %>%
      filter(if (input$has_reviews == TRUE) number_of_reviews > 0
             else id == id) %>%
      filter(price >= input$price_slider[1] & 
               price <= input$price_slider[2]) %>%
      filter(accommodates >= input$accom_slider[1] & 
               accommodates <= input$accom_slider[2]) %>%
      filter(if (input$is_superhost == TRUE) host_is_superhost == TRUE
             else id == id) %>%
      filter(if (input$select == "All") id == id
             else neighbourhood_cleansed == input$select)
  
    # Get the count of filtered listings
    filter_count <- nrow(plot_data)
    
    # Get map pop-up content for listing rating
    popup_rating <- ifelse(plot_data$number_of_reviews > 0,
                           paste0("<b style='color:#FF5A5F;'>&#9733; ",
                                plot_data$review_scores_rating,
                                "</b> (",
                                plot_data$number_of_reviews, ")"),
                           "No Reviews")
    
    # Get map pop-up content for host status
    popup_superhost <- ifelse(plot_data$host_is_superhost == T, 
                              paste0(" &#183; <b style='color:#FF5A5F;'>
                                     &#127894;</b> Superhost"),
                              "")
    
    # Get map pop-up content for guest capacity
    popup_guests <- ifelse(plot_data$accommodates > 1, 
                         paste0(plot_data$accommodates, " guests"), 
                         paste0(plot_data$accommodates, " guest")
                         )
    
    # Compile all content for map pop-up
    popup_content <- paste0(sep = "<br/>",
           paste0("<h5><span style='color:#767676;'>",
                  popup_rating, popup_superhost,
                  " &#183; <u>", plot_data$neighbourhood_cleansed, 
                  ", Singapore</u></span></h5><hr>"),
           paste0("<center><h4><b>$", plot_data$price,
                  "</b> / night</h4></center>"),
           paste0("<center><h6>", popup_guests, "</h6></center>"),
           paste0("<center><h5><b><a href=", plot_data$listing_url,
                  ">", plot_data$name, "</a></b></h5></center>"),
           paste0("<center><img src=", plot_data$picture_url,
                  " width=300 height=180></center>")
           )
    
    # Create Leaflet map of user-filtered Singapore listings
    leaflet(data = plot_data) %>%
      addTiles(
        urlTemplate = paste0("https://tile.jawg.io/ba3f805c-04fb-4fa7-99ef-b9",
        "05aa38b3c8/{z}/{x}/{y}.png?access-token=eIlOZCXWfZIR2t5pqcGt6vcc25pb",
        "scLwwCKzFgtOjISymDP6p3nvlwwLl4mA0qeH"),
      ) %>%
      setView(lng = 103.841959, lat = 1.3521, zoom = 11.5) %>%
      addCircles(
        lat = ~latitude,
        lng = ~longitude,
        stroke = FALSE,
        popup = ~popup_content,
        color = ~palette_fn(room_type),
        radius = 20,
        fillOpacity = 0.5
      ) %>%
      addLegend(
        position = "bottomright",
        title = paste0(
          "Airbnb Listings in Singapore (", filter_count, " results)"),
        pal = palette_fn,
        values = ~room_type,
        opacity = 1
      )
  })
  


  ##### Interactive Page Two ##################################################


  ##### Interactive Page Three ################################################



}
