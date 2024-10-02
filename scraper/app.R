library(shiny)
library(rvest)
library(stringr)
library(glue)
library(dplyr)
library(ggplot2)
library(plotly)

# UI Definition
ui <- fluidPage(
  # Adding custom CSS for a modern look
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap"),
    tags$style(HTML("
      body {
        font-family: 'Roboto', sans-serif;
        background-color: #f0f4f8;
        color: #333;
        margin: 0;
        padding: 20px;
      }
      .title-panel {
        background-color: #d35400;  /* Title panel color */
        color: #fff;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
        text-align: center;
        font-size: 2em;
      }
      .sidebar-panel {
        background-color: #ffffff;  /* Sidebar color */
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      .main-panel {
        background-color: #ffffff;  /* Main content area color */
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #d35400;  /* Headings color */
        margin-bottom: 15px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
      }
      th, td {
        padding: 12px 15px;
        border: 1px solid #ddd;
        text-align: left;
      }
      th {
        background-color: #d35400;  /* Table header color */
        color: white;
        text-align: center;
      }
      td {
        background-color: #f9f9f9;
      }
      tr:hover {
        background-color: #eaeaea;
      }
      .btn-primary {
        background-color: #d35400;  /* Button color */
        color: white;
        border: none;
        padding: 12px 20px;
        margin-top: 10px;
        cursor: pointer;
        border-radius: 5px;
        transition: background-color 0.3s, transform 0.2s;
        font-size: 1em;
      }
      .btn-primary:hover {
        background-color: #c0392b;  /* Button hover color */
        transform: translateY(-2px);
      }
      .table-container {
        overflow-x: auto;
        margin-top: 20px;
      }
      input[type='text'], select {
        width: 100%;
        padding: 12px;
        margin: 5px 0 15px 0;
        border: 1px solid #ccc;
        border-radius: 5px;
        box-sizing: border-box;
        font-size: 1em;
      }
      .plot-title {
        color: #d35400;  /* Plot titles color */
        margin: 10px 0;
      }
    "))
  ),
  
  # UI Layout with tab structure
  fluidRow(
    div(class = "title-panel", h1("Web Scraper with Data Visualization")),
    column(
      3,
      div(class = "sidebar-panel",
          textInput("urlInput", "Enter URL to Scrape", 
                    value = "http://books.toscrape.com/catalogue/category/books/business_35/index.html"),
          selectInput("genreInput", "Select Genre", 
                      choices = c(
                        "Default" = "default", "Travel" = "travel_2", 
                        "Mystery" = "mystery_3", "Historical Fiction" = "historical-fiction_4", 
                        "Sequential Art" = "sequential-art_5", "Classics" = "classics_6",
                        "Philosophy" = "philosophy_7", "Romance" = "romance_8",
                        "Womens Fiction" = "womens-fiction_9", "Fiction" = "fiction_10",
                        "Childrens" = "childrens_11", "Religion" = "religion_12",
                        "Nonfiction" = "nonfiction_13", "Music" = "music_14",
                        "Science Fiction" = "science-fiction_16", 
                        "Sports and Games" = "sports-and-games_17", 
                        "Fantasy" = "fantasy_19", "New Adult" = "new-adult_20",
                        "Young Adult" = "young-adult_21", "Science" = "science_22", 
                        "Poetry" = "poetry_23", "Paranormal" = "paranormal_24", 
                        "Art" = "art_25", "Psychology" = "psychology_26", 
                        "Autobiography" = "autobiography_27", "Parenting" = "parenting_28", 
                        "Adult Fiction" = "adult-fiction_29", "Humor" = "humor_30", 
                        "Horror" = "horror_31", "History" = "history_32", 
                        "Food and Drink" = "food-and-drink_33", 
                        "Christian Fiction" = "christian-fiction_34", 
                        "Business" = "business_35", "Biography" = "biography_36", 
                        "Thriller" = "thriller_37", "Contemporary" = "contemporary_38", 
                        "Spirituality" = "spirituality_39", "Academic" = "academic_40", 
                        "Self Help" = "self-help_41", "Historical" = "historical_42", 
                        "Christian" = "christian_43", "Suspense" = "suspense_44", 
                        "Short Stories" = "short-stories_45", "Novels" = "novels_46", 
                        "Health" = "health_47", "Politics" = "politics_48", 
                        "Cultural" = "cultural_49", "Erotica" = "erotica_50", 
                        "Crime" = "crime_51"),
                      selected = "business_35"),
          actionButton("scrapeButton", "Scrape Data", class = "btn-primary")
      )
    ),
    column(
      9,
      div(class = "main-panel",
          tabsetPanel(
            tabPanel(
              "Scraped Data",
              h3("Scraped Data"),
              uiOutput("scrapedTable")
            ),
            tabPanel(
              "Visualization",
              h3("Data Visualization"),
              div(class = "plot-title", h4("1. Average Price per Rating")),
              plotlyOutput("avgPricePlot"),  
              div(class = "plot-title", h4("2. Price vs Rating")),
              plotlyOutput("scatterPlot"),
              div(class = "plot-title", h4("3. Price Distribution by Availability")),
              plotlyOutput("boxPlot"),
              div(class = "plot-title", h4("4. Price Distribution Histogram")),
              plotlyOutput("priceHistogram"),
              div(class = "plot-title", h4("5. Book Count per Rating")),
              plotlyOutput("ratingCountBar"),
              div(class = "plot-title", h4("6. Availability Distribution")),
              plotlyOutput("availabilityPie")
            )
          )
      )
    )
  )
)

# Server Logic
server <- function(input, output) {
  scraped_data <- reactiveVal()
  
  observeEvent(input$scrapeButton, {
    req(input$urlInput)
    
    # Construct URL based on selected genre
    url <- if (input$genreInput == "default") {
      input$urlInput  # Use manually input URL if "default" is selected
    } else {
      glue("http://books.toscrape.com")
    }
    
    # Scraping logic
    scrape_data <- function(url) {
      page <- read_html(url)
      
      titles <- page %>% 
        html_nodes('.product_pod h3 a') %>% 
        html_attr('title')
      
      urls <- page %>% 
        html_nodes('.product_pod h3 a') %>% 
        html_attr('href') %>% 
        str_replace_all('^../..', 'http://books.toscrape.com/catalogue')
      
      imgs <- page %>% 
        html_nodes('.product_pod .image_container img') %>% 
        html_attr('src') %>% 
        str_replace_all('^../..', 'http://books.toscrape.com/')
      
      ratings <- page %>% 
        html_nodes('.product_pod p.star-rating') %>% 
        html_attr('class') %>% 
        str_replace_all('star-rating ', '')
      
      prices <- page %>% 
        html_nodes('.product_pod .price_color') %>% 
        html_text() %>% 
        str_replace_all("£", "") %>% 
        as.numeric()
      
      availability <- page %>% 
        html_nodes('.product_pod .instock.availability') %>% 
        html_text() %>% 
        str_trim()
      
      # Create a data frame to store scraped data
      data_frame(
        Title = titles,
        URL = urls,
        Image = imgs,
        Rating = ratings,
        Price = prices,
        Availability = availability
      )
    }
    
    # Store scraped data
    scraped_data(scrape_data(url))
    
    # Render scraped data as a table
    output$scrapedTable <- renderUI({
      req(scraped_data())
      scraped_data_df <- scraped_data()
      
      table_html <- "<div class='table-container'><table class='table'><thead><tr>
                      <th>Title</th>
                      <th>Image</th>
                      <th>Rating</th>
                      <th>Price (£)</th>
                      <th>Availability</th>
                      <th>Link</th>
                    </tr></thead><tbody>"
      
      for (i in 1:nrow(scraped_data_df)) {
        table_html <- paste0(table_html, "<tr>
                      <td>", scraped_data_df$Title[i], "</td>
                      <td><img src='", scraped_data_df$Image[i], "' alt='Book Image' style='width:50px;'></td>
                      <td>", scraped_data_df$Rating[i], "</td>
                      <td>", scraped_data_df$Price[i], "</td>
                      <td>", scraped_data_df$Availability[i], "</td>
                      <td><a href='", scraped_data_df$URL[i], "' target='_blank'>View</a></td>
                    </tr>")
      }
      
      table_html <- paste0(table_html, "</tbody></table></div>")
      HTML(table_html)
    })
    
    # Visualization of data
    output$avgPricePlot <- renderPlotly({
      req(scraped_data())
      avg_price_data <- scraped_data() %>%
        group_by(Rating) %>%
        summarize(Avg_Price = mean(Price, na.rm = TRUE))
      
      ggplot(avg_price_data, aes(x = Rating, y = Avg_Price, fill = Rating)) +
        geom_bar(stat = "identity") +
        labs(title = "Average Price per Rating", x = "Rating", y = "Average Price (£)") +
        scale_fill_manual(values = c("#e67e22", "#e74c3c", "#f39c12", "#f1c40f", "#16a085", "#2ecc71")) +  # Custom warm colors
        theme_minimal() +
        theme(legend.position = "none")  # Hide legend
    })
    
    output$scatterPlot <- renderPlotly({
      req(scraped_data())
      ggplot(scraped_data(), aes(x = Price, y = Rating, color = Availability)) +
        geom_point(size = 3) +
        scale_color_manual(values = c("#e67e22", "#c0392b", "#27ae60")) +  # Custom warm colors
        labs(title = "Price vs Rating", x = "Price (£)", y = "Rating") +
        theme_minimal() +
        theme(legend.position = "top")  # Position legend at top
    })
    
    output$boxPlot <- renderPlotly({
      req(scraped_data())
      ggplot(scraped_data(), aes(x = Availability, y = Price, fill = Availability)) +
        geom_boxplot() +
        scale_fill_manual(values = c("#e67e22", "#c0392b", "#27ae60")) +  # Custom warm colors
        labs(title = "Price Distribution by Availability", x = "Availability", y = "Price (£)") +
        theme_minimal() +
        theme(legend.position = "none")  # Hide legend
    })
    
    # New: Price Distribution Histogram
    output$priceHistogram <- renderPlotly({
      req(scraped_data())
      ggplot(scraped_data(), aes(x = Price)) +
        geom_histogram(binwidth = 5, fill = "#3498db", color = "white") +
        labs(title = "Price Distribution", x = "Price (£)", y = "Count") +
        theme_minimal()
    })
    
    # New: Book Count per Rating
    output$ratingCountBar <- renderPlotly({
      req(scraped_data())
      rating_count_data <- scraped_data() %>%
        group_by(Rating) %>%
        summarize(Count = n())
      
      ggplot(rating_count_data, aes(x = Rating, y = Count, fill = Rating)) +
        geom_bar(stat = "identity") +
        labs(title = "Book Count per Rating", x = "Rating", y = "Count") +
        scale_fill_manual(values = c("#e67e22", "#e74c3c", "#f39c12", "#f1c40f", "#16a085", "#2ecc71")) +
        theme_minimal() +
        theme(legend.position = "none")
    })
    
    # New: Availability Distribution Pie Chart
    output$availabilityPie <- renderPlotly({
      req(scraped_data())
      availability_data <- scraped_data() %>%
        group_by(Availability) %>%
        summarize(Count = n())
      
      plot_ly(availability_data, labels = ~Availability, values = ~Count, type = 'pie') %>%
        layout(title = 'Availability Distribution',
               showlegend = TRUE)
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
