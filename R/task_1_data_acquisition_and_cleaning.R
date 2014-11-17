# https://class.coursera.org/dsscapstone-002/wiki/Task_1

setwd("D:/Fan Li/R/10. Capstone Project/R")

library(dplyr)
library(tm)


# Load en_us datasets from RData. See Task 0 for its creation.
load(file="../../DSCapstoneProject_Data/Output/RData/en_us.RData")

blogs <- sample(en_us.blogs, length(en_us.blogs)*0.01)
news <- sample(en_us.news, length(en_us.news)*0.01)
twitter <- sample(en_us.twitter, length(en_us.twitter)*0.01)

save(blogs, news, twitter, file="../../DSCapstoneProject_Data/Output/RData/task_1_blogs_news_twitter_sample.RData")
