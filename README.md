# Airbnb-Reviews-Text-Analysis
Text analysis of user reviews for AirBnB listings in Bronx and Staten Island. Covers "Document Term Matrix", "Topicmodels" and "Sentiment Analysis"

# Running the app directly from RStudio   
shiny::runGitHub("Airbnb-Reviews-Text-Analysis", "sameer-sinha")

# Data Details
Data used for this project can be found [here](http://insideairbnb.com/get-the-data.html), under __New York City, New York, United States__ heading. I have used the compressed files as they have more data

# Data Cleaning

As one of the objectives of our project was to __Creating Predicting Models for Price Estimation__, we carried out necessary steps for data cleaning.

* From the initial analysis of the price field in __listing.csv__, we observed some significant outliers. For the purpose of building a robust predictive model we only look at values between $1 and $500.
* Multiple important features had NULL values. We handled the missing values as
  * Removed unwanted columns
  * For continuous features, replaced null values with the mean
  * For nominal features, replaced null values with the mode or created an additional category for null values
* A new field is created to represent the price of the listing using the formula: Price = Price + Cleaning Price
* After checking the distribution of price and other continuous features, applied log transformation to some of the features, so that their disribution would be closer to normal distribution
* This cleaned data was saved in file __listing_2.csv__ from which we carried out predictive modeling and text analysis
