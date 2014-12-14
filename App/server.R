library(tm)
library(ggplot2)
library(dplyr)
library(ggvis)

load(file="data/gram_dt.RData")
load(file="data/sample_news.RData")

# Helper function to preprocess corpus
CorpusPreprocess <- function(corpus){
  toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
  processed.corpus <- corpus %>%
    tm_map(toSpace, "/|@|\\|()\"") %>%
    #tm_map(content_transformer(tolower)) %>%
    tm_map(removeNumbers) %>%
    #tm_map(removePunctuation) %>%
    tm_map(stripWhitespace)
  return(processed.corpus)
}

# Helper function to generate prediction result
Predict.Word <- function(word.1, word.2){
  pred.3gram <- dt.3gram[key==paste(word.1, word.2)]
  
  if(nrow(pred.3gram) < 5){
    pred.2gram <- dt.2gram[key==word.2]
    if((length(unique(c(pred.3gram$word, pred.2gram$word)))) < 5){
      result <- c(pred.3gram$word, 
                  pred.2gram$word[!pred.2gram$word %in% pred.3gram$word], 
                  dt.1gram$word[!dt.1gram$word %in% pred.3gram$word & !dt.1gram$word %in% pred.2gram$word][1:(5-length(unique(c(pred.3gram$word, pred.2gram$word))))])
    }else{
      result <- c(pred.3gram$word, pred.2gram$word[!pred.2gram$word %in% pred.3gram$word][1:(5-nrow(pred.3gram))])
    }
  }else{
    result <- pred.3gram$word[1:5]
  }
  return(result)
}

# Helper function to continuously predict a whole phrase
Predict.Phrase <- function(phrase){
  phrase.tr <- as.character((VCorpus(VectorSource(phrase)) %>% CorpusPreprocess())[[1]])
  words <- strsplit(phrase.tr, " ")[[1]] %>%
    str_replace_all("[,|.|?|!]", "")
  prediction <- data.frame(ind=1:length(words), word=words[1:length(words)], predict.1=NA, predict.2=NA, predict.3=NA, predict.4=NA, predict.5=NA, score=NA, stringsAsFactors=FALSE)
  
  for(i in 3:length(words)){
    #print(i)
    result <- Predict.Word(words[i-2], words[i-1])
    prediction[i, 3:7] <- result
    if(words[i] %in% result){
      prediction[i, 8] <- 6-which(result==words[i]) 
    }else{
      prediction[i, 8] <- 0
    }
  }
  return(prediction)
}

# Helper function to add tooltip for ggvis

#print(Predict.Word("This", "Shiny"))

shinyServer(function(input, output, session) {
  output$singlePredict <- renderPrint({
    input$submitButton1
    entry <- isolate(input$entry1)
    if(entry==""){
      return(NULL)
    }
    entry.tr <- as.character((VCorpus(VectorSource(entry)) %>% CorpusPreprocess())[[1]])
    words <- strsplit(entry.tr, " ")[[1]] %>%
      str_replace_all("[,|.|?|!]", "")

    predict <- Predict.Word(words[length(words)-1], words[length(words)])
    return(paste0("Prediction: ", paste0(1:5, ".", predict, collapse=", ")))
  })
  
  observe({
    input$submitButton3
    random.news <- sample(sample.news, 1)
    updateTextInput(session, "entry2", value = random.news)
  })
  
  predict.df <- reactive({
    input$submitButton2
    entry <- isolate(input$entry2)
    predict.df <- Predict.Phrase(entry)
    return(predict.df[3:nrow(predict.df),])
  })
  
  
  reactive({
    df <- predict.df()
    df$word.to.predict <- paste(df$ind, df$word, sep=". ")
    df %>%
    ggvis(~reorder(word.to.predict, ind), ~score) %>%
    #  ggvis(~ind, ~score) %>%
    add_axis("x", title = "", properties = axis_props(labels = list(angle=-30, align="right"))) %>%
    add_axis("y", subdivide = 0, values = 0:5) %>%
    layer_bars(width=0.05) %>%
    layer_points(size:=200, key := ~ind) %>%
    add_tooltip(all_predictions, "hover")}) %>%
    bind_shiny("plot")
  
  all_predictions <- function(x) {
    if(is.null(x)) return(NULL)
    if(is.null(x$ind)) return(NULL)
    df <- predict.df()
    row <- df[df$ind == x$ind, ]
    #print(row)
    if(row[, 2] %in% unlist(row[, 3:7])){
      match.row <- which(unlist(row[, 3:7])==row[,2])+2
      row[match.row] <- paste0("<font color='red'>", row[match.row], "</font>")
    }
    #print(row)
    paste0(1:5, ": ", row[3:7], collapse = "<br />")
  }
  
  
})






