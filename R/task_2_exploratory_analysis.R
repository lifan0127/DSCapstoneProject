# https://class.coursera.org/dsscapstone-002/wiki/Task_2

library(tm)
library(RWeka)
library(dplyr)

production.mode = FALSE

if(production.mode){
  warning("Will reload the full dataset")
}else{
  load(file="../../DSCapstoneProject_Data/Output/RData/task_1_blogs_news_twitter_sample.RData")
}


# Helper function to preprocess corpus
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
corpus.preprocess <- function(corpus){
  processed.corpus <- corpus %>%
    tm_map(toSpace, "/|@|\\|") %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeWords, stopwords("english")) %>%
    tm_map(stripWhitespace)
  return(processed.corpus)
}


# Create corpus and apply preprocessing
blogs.corpus <- VCorpus(VectorSource(blogs)) %>% corpus.preprocess()
news.corpus <- VCorpus(VectorSource(news)) %>% corpus.preprocess()
twitter.corpus <- VCorpus(VectorSource(twitter)) %>% corpus.preprocess()


# Create document term matrix (dtm)
blogs.dtm <- DocumentTermMatrix(blogs.corpus) %>% removeSparseTerms(0.95)
news.dtm <- DocumentTermMatrix(news.corpus) %>% removeSparseTerms(0.95)
twitter.dtm <- DocumentTermMatrix(twitter.corpus) %>% removeSparseTerms(0.99)


# Frequnt words
# Helper function to find the most frequent n words
most.freq <- function(dtm, n=5){
  freq <- colSums(as.matrix(dtm))
  return(freq[order(freq, decreasing=TRUE)][1:n])
}

# Blogs frequency: one will  can like just 
most.freq(blogs.dtm)

# News frequency: said will  one  new  can
most.freq(news.dtm)

# Twitter frequency: just like love  get good
most.freq(twitter.dtm)




# Create 2-gram
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))

blogs.dtm.2g <- DocumentTermMatrix(blogs.corpus, control=list(tokenize = BigramTokenizer)) %>% removeSparseTerms(0.995) 
news.dtm.2g <- DocumentTermMatrix(news.corpus, control=list(tokenize = BigramTokenizer)) %>% removeSparseTerms(0.995) 
twitter.dtm.2g <- DocumentTermMatrix(twitter.corpus, control=list(tokenize = BigramTokenizer)) %>% removeSparseTerms(0.999) 

# Blogs frequency 2gram: last year   new york  dont know  years ago first time 
most.freq(blogs.dtm.2g)

# News frequency 2gram: last year    new york high school    st louis   years ago
most.freq(news.dtm.2g)

# Twitter frequency 2gram: right now       cant wait       dont know      last night looking forward
most.freq(twitter.dtm.2g)




# Create 3-gram
TrigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))

blogs.dtm.3g <- DocumentTermMatrix(blogs.corpus, control=list(tokenize = TrigramTokenizer)) %>% removeSparseTerms(0.9995) 
news.dtm.3g <- DocumentTermMatrix(news.corpus, control=list(tokenize = TrigramTokenizer)) %>% removeSparseTerms(0.9995) 
twitter.dtm.3g <- DocumentTermMatrix(twitter.corpus, control=list(tokenize = TrigramTokenizer)) %>% removeSparseTerms(0.9999) 

# Blogs frequency 3gram: 
most.freq(blogs.dtm.3g)

# News frequency 3gram: 
most.freq(news.dtm.3g)

# Twitter frequency 3gram: 
most.freq(twitter.dtm.3g)














