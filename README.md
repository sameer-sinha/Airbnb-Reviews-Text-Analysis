# Airbnb-Reviews-Text-Analysis
Text analysis of user reviews for AirBnB listings in Bronx and Staten Island. Covers "Document Term Matrix", "Topicmodels" and "Sentiment Analysis"

# Running the app directly from RStudio   
shiny::runGitHub("Airbnb-Reviews-Text-Analysis", "sameer-sinha")

# Screenshot
<img width="1158" alt="screenshot" src="https://cloud.githubusercontent.com/assets/23367652/25776161/f441be02-3284-11e7-97dc-8ad281e3a3d2.png">


# Data Details
Data used for this project can be found [here](http://insideairbnb.com/get-the-data.html), under __New York City, New York, United States__ heading. We used the compressed files as they have more data.

# Data Cleaning

As one of the objectives of our project was to __Creating Predicting Models for Price Estimation__, we carried out necessary steps for data cleaning. We used the tool [JMP Pro 13](https://www.jmp.com/en_us/home.html) for the same.

* From the initial analysis of the price field in __listing.csv__, we observed some significant outliers. For the purpose of building a robust predictive model we only look at values between $1 and $500.
* Multiple important features had NULL values. We handled the missing values as
  * Removed unwanted columns
  * For continuous features, replaced null values with the mean
  * For nominal features, replaced null values with the mode or created an additional category for null values
* A new field is created to represent the price of the listing using the formula: Price = Price + Cleaning Price
* After checking the distribution of price and other continuous features, applied log transformation to some of the features, so that their disribution would be closer to normal distribution
* This cleaned data was saved in file __listing 2.csv__ from which we carried out predictive modeling and text analysis

# Data Preparation

Apart from the basic data cleaning, some processing was required to prepare data for text analytics. The code for same can be found above. As the algorithms for text processing takes time to run, especially for data of this size, I saved the results in .RData files and further used it in ui.R and server.R files of __Shiny__.

# Text Analytics

## Text Mining
* Used [tm](https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf) package of R for __text mining__.
 * Created a corpus of user reviews and carried out necessary cleaning of the corpus
 * Used [SnowballC](https://cran.r-project.org/web/packages/SnowballC/SnowballC.pdf) to implement Porter's word stemming algorithm
 * Created __Document Term Matrix__ from the cleaned corpus.
 * Term count from this DTM is used to find high frequency term either based on 
   * A give range of top percentage
   * A minimum number of frequency
* Used [wordcloud](https://cran.r-project.org/web/packages/wordcloud/wordcloud.pdf) package to create word cloud

## Topic Models
* Used [slam](https://cran.r-project.org/web/packages/slam/slam.pdf) package to remove sparse terms from dtm and hence reduce the dimension of DTM
* Used [topicmodels](https://cran.r-project.org/web/packages/topicmodels/vignettes/topicmodels.pdf) package of R to cluster group of words into 10 topics and to get the posterior probability of the topics for each document and and the terms for each topic

## Sentiment Analysis
* Used [qdap](https://cran.r-project.org/web/packages/qdap/qdap.pdf) for sentiment analysis 
* Created polarity score for each review using the polarity function of qdap package
* Combined the polarity variable with reviews dataframe to plot results and check the correlation between polarity and user ratings
* Helpful and Not Helpful variables are created based on a threshold (depending upon minimum and maximum values) and a spineplot is created for visualization

## Visualization of Text Mining and Topic Models
* Used [ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf) package to show bar graph  
* Used [shiny](http://shiny.rstudio.com/) to create interactive visualization

# Future Agendas
* Extend the application by using [tf-idf](https://en.wikipedia.org/wiki/Tf%E2%80%93idf), term frequency–inverse document frequency, in place of frequencies of term as entries, as it will give a measure of relative importance of a word to a document.
* Use a precompiled list of words with positive and negative meanings
* Create visualization for sentiment analysis
