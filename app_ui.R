# Load packages
library("shiny")
library("tidyverse")
library("leaflet")

# Read data (setwd to root first)
data_sing <- read.csv("data/singapore_listings.csv", encoding="latin1")


#### Introduction #############################################################

intro <- tabPanel(
  title = tags$header("Introduction")
)


##### Interactive tab one #####################################################

# Convert price column to vector of numbers
data_sing$price <- as.numeric(gsub("[$,]", "", data_sing$price))


# Set default max slider range for better control (as opposed to the
# max price from the dataset due to heavy left skew distribution)
min_price <- min(data_sing$price)
max_price <- 500

slider_price <- sliderInput(
  inputId = "price_slider",
  label = "Listing Price ($SGD per night)",
  min = min_price,
  max = max_price,
  sep = ",",
  pre = "$",
  value = c(min_price, max_price),
  dragRange = TRUE
)

# Allow user to set new max price range
change_max_range <- textInput(
  inputId = "textbox",
  label = tags$h6("Set max price for slider")
)

min_guests <- min(data_sing$accommodates)
max_guests <- max(data_sing$accommodates)

slider_accomodates <- sliderInput(
  inputId = "accom_slider",
  label = "Number of guests",
  min = min_guests,
  max = max_guests,
  step = 1,
  value = 1,
  width = '80%'
)

# Sort neigbhourhoods in order of num listings
sorted <- data_sing %>%
  group_by(neighbourhood_cleansed) %>%
  summarize(num_listings = n()) %>%
  arrange(desc(num_listings))

select_neigbourhood <- selectInput(
  inputId = "select",
  label = "Filter by neigbourhood",
  choices = c("All", sorted$neighbourhood_cleansed)
)

checkbox_superhost <- checkboxInput(
  inputId = "is_superhost",
  label = tags$strong("Superhost Listings Only")
)

checkbox_has_reviews <- checkboxInput(
  inputId = "has_reviews",
  label = "Filter out listings with no reviews"
)

slider_score <- sliderInput(
  inputId = "score_slider",
  label = "Review score",
  min = 0,
  max = 5,
  step = 0.1,
  value = c(0, 5),
  dragRange = TRUE,
  width = "80%"
)

# Define a layout for interactive page
page_one <- tabPanel(
  title = tags$header("Interactive Map"),
  sidebarLayout(
    sidebarPanel(
      tags$h3("Map filter options"),
      tags$hr(),
      slider_score,
      checkbox_has_reviews,
      tags$hr(),
      slider_price,
      fluidRow(
        column(7,
               change_max_range
        ),
        column(5,
               br(),
               br(),
               actionButton("button", "change")
        ),
      ),
      tags$hr(),
      slider_accomodates,
      tags$hr(),
      select_neigbourhood,
      tags$hr(),
      checkbox_superhost
    ),
    mainPanel(
      HTML("<center><h3>Singapore Airbnb Listings (26 October, 2020)
           </h3></center>"),
      tags$style(type = "text/css",
                 "#m_sing {height: calc(100vh - 150px) !important;}"),
      leafletOutput("m_sing")
    )
  )
)

# Define a ui for the application
ui <- navbarPage(
  windowTitle = ("Airbnb Singapore - Map Visualization"),
  title = tags$strong("Airbnb Singapore Data Visualizations"),
  page_one
)