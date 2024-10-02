Web Scraper with Data Visualization
This is a Shiny web application that scrapes data from a book website and provides several visualizations based on the scraped data. The app allows users to input a URL and select a genre of books to scrape information such as book titles, ratings, prices, availability, and more. The data is then visualized through interactive plots using Plotly.

Features
Scrape book data from Books to Scrape, including title, price, rating, and availability.
Provides different genres to scrape data from, using a drop-down selector.
Visualize the scraped data with:
Average price per rating
Price vs. rating scatter plot
Price distribution based on availability
Price distribution histogram
Book count per rating
Availability distribution pie chart
Modern UI styling with custom CSS and responsive layout.
Technologies Used
R Shiny: For building the web application.
rvest: For web scraping the book data.
dplyr: For data manipulation and summarization.
ggplot2 and plotly: For creating interactive data visualizations.
HTML and CSS: For customizing the UI appearance.

Prerequisites
Make sure you have the following installed:
R (version 4.0 or higher)
RStudio (optional but recommended)
The following R libraries:
shiny
rvest
stringr
glue
dplyr
ggplot2
plotly

Installation
Clone the repository
Copy code
Running the App
Open the app.R file in RStudio, or use the following command in the R console:
R
Copy code
shiny::runApp('app.R')
The Shiny app will launch in your web browser, and you can interact with it by entering a URL to scrape or selecting a genre.

Usage
URL Input: Enter a URL from the Books to Scrape website.
Genre Selector: Choose a genre from the dropdown menu to scrape book data specific to that genre.
Scrape Data: Click the "Scrape Data" button to fetch book information from the selected URL or genre.
Data Visualization: View the data in various plots and tables under the "Visualization" tab.

Visualizations:

Custom CSS Styling
The app includes custom CSS to enhance its look and feel. It uses the Roboto font and a clean, modern layout with well-structured panels and tables. Hover effects and transitions are also applied to buttons for better user experience.

License
This project is licensed under the MIT License.

