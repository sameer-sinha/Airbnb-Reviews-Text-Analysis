### Script to run text analytics on Airbnb NYC data 
###   1. WordCloud
###   2. Topic Modeling
###   3. Sentiment Analysis

### Results are saved in rdata file for visualization of wordcloud and topic models in Shiny

library(dplyr)
library(ggplot2)
library(tidyr)
library(ggmap)
library(cluster)   
library(tm)
library(topicmodels)
library(slam)
library(SnowballC)
library(wordcloud)


#listing <- read.csv("listings 2.csv")
#reviews <- read.csv("reviews.csv")

load("lrj_df.rda")  # Rdata file containg dataframes - listing, reviews and joined_data

names(listing)
nrow(listing) # 39933
head(listing)
unique(listing$neighbourhood_group_cleansed) # 5
unique(listing$neighbourhood_cleansed)    # 214
colSums(is.na(listing))

names(reviews)
nrow(reviews) # 632087
head(reviews)
colSums(is.na(reviews))

### Joining review and listing data

# joined_data <- reviews %>% 
#   left_join(select(listing,id,neighbourhood_group_cleansed,neighbourhood_cleansed), 
#             by = c("listing_id" = "id"))

names(joined_data)
nrow(joined_data)
colSums(is.na(joined_data))
#save(listing,reviews,joined_data, file = "lrj_df.rda")


### Number of records in each borough
joined_data %>% group_by(neighbourhood_group_cleansed) %>% 
  summarise(n = n())

#                         <fctr>  <int>
# 1                        Bronx   8860
# 2                     Brooklyn 248204
# 3                    Manhattan 303564
# 4                       Queens  60663
# 5                Staten Island   4389
# 6                           NA   6407


### Number of records in each neighbourhood grouped by borough
joined_data %>% filter(neighbourhood_group_cleansed == "Manhattan") %>% group_by(neighbourhood_group_cleansed,
                                                                                 neighbourhood_cleansed) %>%
  summarise(n = n())

# <fctr>                 <fctr> <int>
# 1                     Manhattan      Battery Park City   582
# 2                     Manhattan                Chelsea 17742
# 3                     Manhattan              Chinatown  5995
# 4                     Manhattan           Civic Center   524
# 5                     Manhattan            East Harlem 20014
# 6                     Manhattan           East Village 36402
# 7                     Manhattan     Financial District  3171
# 8                     Manhattan      Flatiron District  1002
# 9                     Manhattan               Gramercy  4982
# 10                    Manhattan      Greenwich Village  6047
# # ... with 22 more rows


### Saving reviews for each borough in corresponding data frames using dplyr filter function on the joined dataframe 

bronx.reviews <- filter(joined_data,neighbourhood_group_cleansed=="Bronx")
brooklyn.reviews <- filter(joined_data,neighbourhood_group_cleansed=="Brooklyn")
manhattan.reviews <- filter(joined_data,neighbourhood_group_cleansed=="Manhattan")
staten.reviews <- filter(joined_data,neighbourhood_group_cleansed=="Staten Island")
queens.reviews <- filter(joined_data,neighbourhood_group_cleansed=="Queens")

#save(bronx.reviews,brooklyn.reviews,manhattan.reviews,staten.reviews,queens.reviews, file = "borough_reviews.rda")

### As term count (carried out below on respective cleaned corpus) for Manhattan and other boroughs are throwing "out of memory" error, I selected boroughs having least number of records for now
### As seen from the output above, I will use data for staten island and bronx for further analysis 
### Random sampling can be used on the data for other boroughs to get a reasonable sized chunk of data and these analysis can be carried out on those chunks

#save(staten.reviews, file = "staten.reviews.rda")
#save(bronx.reviews, file = "bronx.reviews.rda")

load("bronx.reviews.rdaa")
load("staten.reviews.rda")



#Create volatile corpora for staten island and bronx

staten.reviews.corpus <- VCorpus(DataframeSource(select(staten.reviews,comments)))
#transaformation of the corpora
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus, content_transformer(tolower)) 
#Interface to apply transformation functions to corpora.
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus.clean, removePunctuation)
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus.clean, removeNumbers)
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus.clean, removeWords, stopwords("english"))
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus.clean, stemDocument, language="english") 
#perform stemming which truncates words
staten.reviews.corpus.clean <- tm_map(staten.reviews.corpus.clean,stripWhitespace)


bronx.reviews.corpus <- VCorpus(DataframeSource(select(bronx.reviews,comments)))
#transaformation of the corpora
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus, content_transformer(tolower)) 
#Interface to apply transformation functions to corpora.
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus.clean, removePunctuation)
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus.clean, removeNumbers)
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus.clean, removeWords, stopwords("english"))
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus.clean, stemDocument, language="english") 
#perform stemming which truncates words
bronx.reviews.corpus.clean <- tm_map(bronx.reviews.corpus.clean,stripWhitespace)


#### Creating Documter Term Matrix
dtm_staten <- DocumentTermMatrix(staten.reviews.corpus.clean)
dtm_bronx <- DocumentTermMatrix(bronx.reviews.corpus.clean)


# Creates total frequency for each word
#Very hard to see, so let's make a plot

term.count.staten <- as.data.frame(as.table(dtm_staten)) %>%
  group_by(Terms) %>%
  summarize(n=sum(Freq))


term.count.bronx <- as.data.frame(as.table(dtm_bronx)) %>%
  group_by(Terms) %>%
  summarize(n=sum(Freq))

#save(dtm_staten,term.count.staten, file = "staten_dtm_termCount.rda")
#save(dtm_bronx,term.count.bronx, file = "bronx_dtm_termCount.rda")

### These values are further used in server.R to create frequency plots and wordcloud

################################
# TOPIC MODELING
################################

## set.up.dtm.for.lda.1
library(topicmodels)
library(slam)


### Remove the sparse reviews

dtm_staten.lda <- removeSparseTerms(dtm_staten, 0.98)
review.id <- staten.reviews$id[row_sums(dtm_staten.lda) > 0]
dtm_staten.lda <- dtm_staten.lda[row_sums(dtm_staten.lda) > 0,]

dtm_bronx.lda <- removeSparseTerms(dtm_bronx, 0.98)
review.id <- bronx.reviews$id[row_sums(dtm_bronx.lda) > 0]
dtm_bronx.lda <- dtm_bronx.lda[row_sums(dtm_bronx.lda) > 0,]



### Running the LDA algorithm with toatl number of topics, k = 10
lda.staten <- LDA(dtm_staten.lda,k=10,method="Gibbs",
                  control = list(seed = 2011, burnin = 1000,
                                 thin = 100, iter = 5000))


lda.bronx <- LDA(dtm_bronx.lda,k=10,method="Gibbs",
                  control = list(seed = 2011, burnin = 1000,
                                 thin = 100, iter = 5000))

#save(lda.staten,file='lda_staten_results.rda')
#save(lda.bronx,file='lda_bronx_results.rda')

#load("lda_staten_results.rda")
#load("lda_bronx_results.rda")


#get the posterior probability of the topics for each document and of the terms for each topic
post.lda.staten <- posterior(lda.staten) 
post.lda.bronx <- posterior(lda.bronx) 


#save(post.lda.staten, file="post.lda.staten")
#save(post.lda.bronx, file="post.lda.bronx")

#load("post.lda.staten")
#load("post.lda.bronx")

### Visualization for topics carried out in server.R



################################
# SENTIMENT ANALYSIS
################################

library(qdap)
library(data.table)

### Using the polarity function in qdap padckage to create a polarity score of each review

temp.reviews.staten <- reviews %>% 
  left_join(select(listing,id,neighbourhood_group_cleansed,neighbourhood_cleansed,review_scores_rating,review_scores_value), 
            by = c("listing_id" = "id")) 			

staten.reviews1 <- filter(temp.reviews.staten,neighbourhood_group_cleansed=="Staten Island")

#save(temp.reviews.staten,staten.reviews1, file="temp_staten_reviews1")
#load("temp_staten_reviews1")


temp.reviews.bronx <- reviews %>% 
  left_join(select(listing,id,neighbourhood_group_cleansed,neighbourhood_cleansed,review_scores_rating,review_scores_value), 
            by = c("listing_id" = "id")) 			

bronx.reviews1 <- filter(temp.reviews.bronx,neighbourhood_group_cleansed=="Bronx")

#save(temp.reviews.bronx,bronx.reviews1, file="temp_bronx_reviews1")
#load("temp_bronx_reviews1")


pol.df.staten <- polarity(staten.reviews1$comments)$all
#save(pol.df.staten,file='pol.df.staten.rda')

### Use the polarity variable and then combine results with review data frame 
sent_df_staten = data.frame(polarity=pol.df.staten$polarity, listing = staten.reviews1, stringsAsFactors=FALSE)


pol.df.bronx <- polarity(bronx.reviews1$comments)$all
#save(pol.df.bronx,file='pol.df.bronx.rda')

### Use the polarity variable and then combine results with review data frame 

sent_df_bronx = data.frame(polarity=pol.df.bronx$polarity, listing = bronx.reviews1, stringsAsFactors=FALSE)


### Plot results and check the correlation betweeen polarity and scores rating

sent_df_staten$listing.review_scores_rating<-as.numeric(sent_df_staten$listing.review_scores_rating)

sent_df_staten %>%
  group_by(listing.review_scores_rating) %>%
  summarize(mean.polarity=mean(polarity,na.rm=TRUE)) %>%
  ggplot(aes(x=listing.review_scores_rating,y=mean.polarity)) +  geom_bar(stat='identity',fill="blue") +  
  ylab('Mean Polarity') + xlab('review_scores_rating')  + theme(text=element_text(size=20))


min(listing$review_scores_value, na.rm = TRUE)
max(listing$review_scores_value, na.rm = TRUE)

### Create helpful variable and plot by helpful
sent_df_staten$helpful[sent_df_staten$listing.review_scores_value<3]<-"Not Helpful"
sent_df_staten$helpful[sent_df_staten$listing.review_scores_value>=3]<-"Helpful"

spineplot(as.factor(sent_df_staten$helpful)~as.factor(sent_df_staten$listing.review_scores_rating),col = c("red3", "grey", "green3"))

### Correlation between helpfulness and polarity
summary(sent_df_staten)
### Correction for NA
sent_df_staten$polarity[is.na(sent_df_staten$polarity)]=0
colSums(is.na(sent_df_staten))
sent_df_staten <- na.omit(sent_df_staten)
### Changing useful from factor to numeric

sent_df_staten$listing.review_scores_value=as.numeric(paste(sent_df_staten$listing.review_scores_value))
### Correlation between polarity and useful
cor(sent_df_staten$polarity,sent_df_staten$listing.review_scores_value)


sent_df_bronx$listing.review_scores_rating<-as.numeric(sent_df_bronx$listing.review_scores_rating)

sent_df_bronx %>%
  group_by(listing.review_scores_rating) %>%
  summarize(mean.polarity=mean(polarity,na.rm=TRUE)) %>%
  ggplot(aes(x=listing.review_scores_rating,y=mean.polarity)) +  geom_bar(stat='identity',fill="blue") +  
  ylab('Mean Polarity') + xlab('review_scores_rating')  + theme(text=element_text(size=20))


min(listing$review_scores_value, na.rm = TRUE)
max(listing$review_scores_value, na.rm = TRUE)

### Create helpful variable and plot by helpful
sent_df_bronx$helpful[sent_df_bronx$listing.review_scores_value<3]<-"Not Helpful"
sent_df_bronx$helpful[sent_df_bronx$listing.review_scores_value>=3]<-"Helpful"

spineplot(as.factor(sent_df_bronx$helpful)~as.factor(sent_df_bronx$listing.review_scores_rating),col = c("red3", "grey", "green3"))

### Correlation between helpfulness and polarity
summary(sent_df_bronx)
### Correction for NA
sent_df_bronx$polarity[is.na(sent_df_bronx$polarity)]=0
colSums(is.na(sent_df_bronx))
sent_df_bronx <- na.omit(sent_df_bronx)
### Changing useful from factor to numeric

sent_df_bronx$listing.review_scores_value=as.numeric(paste(sent_df_bronx$listing.review_scores_value))
### Correlation between polarity and useful
cor(sent_df_bronx$polarity,sent_df_bronx$listing.review_scores_value)
