library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinyjs)
library(httr)

# Define the OAuth credentials
google_client_id <- "276552974627-sfdslkdcbabbr95kvo8le67gcajb6lnl.apps.googleusercontent.com"
google_client_secret <- "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"

# Define OAuth scopes
scopes <- c("https://www.googleapis.com/auth/userinfo.profile", 
            "https://www.googleapis.com/auth/userinfo.email")


# Clean column names and preprocess data
names(car_data) <- make.names(names(car_data))
car_data$ARAI.Certified.Mileage <- as.numeric(gsub("[^0-9.]", "", car_data$ARAI.Certified.Mileage))
car_data$Ex.Showroom_Price.Rs.. <- as.numeric(gsub(",", "", car_data$Ex.Showroom_Price.Rs..))

# Define the UI
ui <- fluidPage(
  useShinyjs(),
  
  # Add global custom CSS
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f4f6f9;
        font-family: 'Roboto', sans-serif;
        color: #333;
      }
      h1, h3 {
        text-align: center;
        color: #1a5276;
        font-weight: 700;
      }
      .navbar-default {
        background-color: #1a5276;
        border-color: #1a5276;
      }
      .navbar-default .navbar-brand {
        color: white;
        font-weight: bold;
      }
      .navbar-default .navbar-nav > li > a {
        color: white;
      }
      .btn-primary {
        background-color: #2e86c1;
        border-color: #1a5276;
      }
      .btn-primary:hover {
        background-color: #1a5276;
      }
      .panel {
        border: none;
        box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.1);
        margin-top: 10px;
      }
      .table th, .table td {
        text-align: center;
        vertical-align: middle;
      }
    "))
  ),
  
  # Main UI structure
  conditionalPanel(
    condition = "output.is_logged_in === false",
    fluidRow(
      column(
        width = 12,
        div(
          style = "text-align:center; margin-top: 100px;",
          tags$h1("Car Recommendation System"),
          tags$h3("Please log in to continue"),
          actionButton("login_btn", "Login with Google", class = "btn-primary", style = "margin-top: 20px;"),
          tags$br(),
          tags$img(src = "https://www.shutterstock.com/shutterstock/photos/428975230/display_1500/stock-vector-retro-car-collage-428975230.jpg", 
                   height = "450px", style = "margin-top: 20px;")
        )
      )
    )
  ),
  
  conditionalPanel(
    condition = "output.is_logged_in === true",
    navbarPage(
      title = "Car Recommendation System",
      
      
      # Dashboard Tab
      tabPanel(
        "DASHBOARD",
        fluidPage(
          titlePanel(div("ABOUT US", style = "color: #1a5276;")),
          div(
            style = "margin: 20px; padding: 15px; background-color: #ffffff; border-radius: 8px; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.1);",
            h4("Car Price Prediction and Analysis Portal"),
            p("This car price prediction and analysis portal provides a comprehensive platform for analyzing and comparing prices across various car brands and models. The portal leverages a predictive model to estimate car prices based on factors such as brand, fuel type, body style, mileage, and seating capacity."),
            tags$ul(
              tags$li("Price Prediction: The portal estimates car prices based on features such as mileage, body type, and fuel type."),
              tags$li("Brand and Model Analysis: Compare specifications and view price trends across different brands."),
              tags$li("Filter and Sort Options: Advanced filtering options allow users to select cars by mileage, price range, and brand."),
              tags$li("Visual Data Insights: Graphical representations of price predictions, mileage comparisons, and more make data analysis intuitive."),
              tags$li("Recommendation Engine: The system recommends top choices that meet user preferences.")
            )
          )
        )
      ),
      
      # Explore Cars Tab
      tabPanel(
        "Explore Cars",
        fluidPage(
          fluidRow(
            column(
              width = 4,
              div(
                style = "padding: 20px; background-color: #ffffff; border-radius: 8px; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.1);",
                tabsetPanel(
                  tabPanel("Basic Filters",
                           sliderInput("mileage", "Preferred Mileage (km/l):", min = 3, max = 25, value = c(3, 10)),
                           sliderInput("price", "Price Range (Rs.):", min = min(car_data$Ex.Showroom_Price.Rs.., na.rm = TRUE),
                                       max = max(car_data$Ex.Showroom_Price.Rs.., na.rm = TRUE), value = c(500000, 2000000)),
                           selectInput("fuel_type", "Fuel Type:", choices = unique(car_data$Fuel_Type), selected = "Petrol")
                  ),
                  tabPanel("Transmission & Capacity",
                           selectInput("transmission", "Transmission Type:", choices = c("Manual", "Automatic", "DTC", "AMT"), selected = "Manual"),
                           selectInput("seating_capacity", "Seating Capacity:", choices = c(2, 4, 5, 6, 7, 8, 9, 16), selected = 5)
                  ),
                  tabPanel("Sort Options",
                           selectInput("sort_by", "Sort By:", choices = c("Price" = "Ex.Showroom_Price.Rs..", "Mileage" = "ARAI.Certified.Mileage"))
                  )
                )
              )
            ),
            # Top Car Recommendations below the filters
            fluidRow(
              column(
                width = 8,
                h4("Top Car Recommendations"),
                tableOutput("recommendations")
              )
            )
          )
        )
      ),
      
      # Model Visualization Tab
      tabPanel(
        "Model Visualization",
        fluidPage(
          titlePanel(div("Model Analysis", style = "color: #1a5276;")),
          selectInput("graph_type", "Select Graph:", 
                      choices = list("Actual vs. Predicted Prices" = "lm_plot",
                                     "Price Distribution by Car Type" = "box_plot",
                                     "Price vs Mileage by Fuel Type" = "scatter_price_mileage",
                                     "Residuals Plot" = "residuals_plot")),
          plotlyOutput("selected_plot")
        )
      ),
      #logout tab
      tabPanel(
        div("Logout", class = "logout-tab"),
        fluidPage(
          fluidRow(
            column(
              width = 12,
              div(
                style = "text-align: center; margin-top: 50px; padding: 20px; background-color: #ffffff; border-radius: 8px; box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.1);",
                h3("Are you sure you want to log out?", style = "color: #1a5276;"),
                actionButton("confirm_logout", "Logout", class = "btn btn-logout", style = "margin-top: 20px;")
              )
            )
          )
        )
      )
    )
  )
)

# Server logic (no changes made for enhancement)
server <- function(input, output, session) {
  # Reactive value to track login status
  is_logged_in <- reactiveVal(FALSE)
  
  # Reactive output for login condition
  output$is_logged_in <- reactive({ is_logged_in() })
  outputOptions(output, "is_logged_in", suspendWhenHidden = FALSE)
  
  # Google OAuth authentication
  observeEvent(input$login_btn, {
    req(input$login_btn)
    
    oauth_endpoints("google")
    myapp <- oauth_app("google", key = google_client_id, secret = google_client_secret)
    goog_auth <- oauth2.0_token(oauth_endpoints("google"), myapp, scope = scopes, cache = FALSE)
    
    user_info <- GET("https://www.googleapis.com/oauth2/v2/userinfo", config(token = goog_auth))
    user_data <- content(user_info, as = "parsed", simplifyVector = TRUE)
    
    output$user_info <- renderText({ paste("Welcome,", user_data$name) })
    is_logged_in(TRUE)
    
    # Logout logic
    observeEvent(input$confirm_logout, {
      user_status(FALSE) # Set user as logged out
      shinyjs::alert("You have been logged out successfully.")
    })
    
    
  })
  
  # Render recommendations
  output$recommendations <- renderTable({
    filtered_data <- car_data %>%
      filter(
        ARAI.Certified.Mileage >= input$mileage[1],
        ARAI.Certified.Mileage <= input$mileage[2],
        Ex.Showroom_Price.Rs.. >= input$price[1],
        Ex.Showroom_Price.Rs.. <= input$price[2],
        Fuel_Type == input$fuel_type
      )
    filtered_data
  })
  
  # Render plots
  output$selected_plot <- renderPlotly({
    if (input$graph_type == "lm_plot") {
      p <- ggplot(data.frame(actual = testSet$Ex.Showroom_Price.Rs.., predicted = lm_pred), 
                  aes(x = actual, y = predicted)) +
        geom_point() +
        geom_abline(intercept = 0, slope = 1, color = "red") +
        labs(title = "Actual vs. Predicted Prices",
             subtitle = "Linear Regression Model",
             x = "Actual Price (Rs.)",
             y = "Predicted Price (Rs.)")
      ggplotly(p)
      
    } else if (input$graph_type == "box_plot") {
      p <- ggplot(car_data, aes(x = Type, y = Ex.Showroom_Price.Rs..)) +
        geom_boxplot(fill = "#45799b") +
        labs(title = "Price Distribution by Car Type",
             x = "Car Type", y = "Price (Rs.)")
      ggplotly(p)
      
    } else if (input$graph_type == "scatter_price_mileage") {
      p <- ggplot(car_data, aes(x = ARAI.Certified.Mileage, y = Ex.Showroom_Price.Rs.., color = Fuel_Type)) +
        geom_point(alpha = 0.6) +
        labs(title = "Price vs Mileage by Fuel Type",
             x = "Mileage (km/l)", y = "Price (Rs.)")
      ggplotly(p)
      
    } else if (input$graph_type == "residuals_plot") {
      residuals_data <- data.frame(actual = testSet$Ex.Showroom_Price.Rs.., predicted = lm_pred)
      residuals_data$residuals <- residuals_data$actual - residuals_data$predicted
      
      p <- ggplot(residuals_data, aes(x = predicted, y = residuals)) +
        geom_point(alpha = 0.6) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
        labs(title = "Residuals Plot",
             x = "Predicted Price (Rs.)", y = "Residuals (Actual - Predicted)")
      ggplotly(p)
    }
  })
}

# Run the app
shinyApp(ui, server)




