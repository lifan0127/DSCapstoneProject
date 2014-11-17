# https://class.coursera.org/dsscapstone-002/wiki/Task_0

setwd("D:/Fan Li/R/10. Capstone Project/R")


library(dplyr)

# Issue 1: there is a line ending problem with the txt files. 
# Needed to go to notepad++ to delete and recreate the final line.

# Issue 2: en_us.news.txt contains Control-Z characters that prevent reading the rest of the file by readLines.
# Solution: use the customized sReadLines() function.
# Ref: http://stackoverflow.com/a/15876643

# Issue 3: en_us.twitter.txt contains null characters that truncate the rest of the line
# Solution: manual removal in Notepad++ because there are only 4 occurrences.

sReadLines <- function(fnam) {
  f <- file(fnam, "rb")
  res <- readLines(f)
  close(f)
  res
}

en_us.blogs <- sReadLines("../../DSCapstoneProject_Data/Data/final/en_US/en_US.blogs.txt")

en_us.news <- sReadLines("../../DSCapstoneProject_Data/Data/final/en_US/en_US.news.txt")

en_us.twitter <- sReadLines("../../DSCapstoneProject_Data/Data/final/en_US/en_US.twitter.txt")

save(en_us.blogs, en_us.news, en_us.twitter, file="../../DSCapstoneProject_Data/Output/RData/en_us.RData")

# Quiz 1

# Q1
# en_US.blogs.txt file size: 205 MB


# Q2
# en_US.twitter.txt contain 2,360,148 lines (from Notepad++)


# Q3
max(nchar(en_us.blogs))  # 40835
max(nchar(en_us.news))  # 11384
max(nchar(en_us.twitter))  # 213


# Q4
library(stringr)
love <- sum(str_detect(en_us.twitter, "love"))  # 90956
hate <- sum(str_detect(en_us.twitter, "hate"))  # 22138
love/hate  # 4.108592


# Q5
en_us.twitter[str_detect(en_us.twitter, "biostats")]


# Q6
sum(str_detect(en_us.twitter, "A computer once beat me at chess, but it was no match for me at kickboxing"))
