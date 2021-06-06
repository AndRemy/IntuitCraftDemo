# Title     : TODO
# Objective : TODO
# Created by: Andre
# Created on: 6/4/2021

#install.packages("wordcloud")
#install.packages("RColorBrewer")
#install.packages("wordcloud2")

library(quanteda)
library(RColorBrewer)
library(ggplot2)

library(wordcloud)
library(RColorBrewer)
library(wordcloud2)

library(tm)

library(dplyr)
library(stringr)
library(tidytext)

library(tidyr)
library(igraph)
library(ggraph)

#necessary file for Windows
setwd("C:/Users/Andre/Documents/AndRemy/Sandbox/IntuitCraftDemo/")

custom_stop_words <- read.csv("custom_stop_words.csv", stringsAsFactors = FALSE)
tweets_draft <- read.csv("QB_Tweets_2021-06-04.csv", stringsAsFactors = FALSE)

tweets_draft$created_at <- as.Date(tweets_draft$created_at, "%Y-%m-%d")

tweets <- data.frame(
    text=tweets_draft$text,
    id=format(tweets_draft$created_at, format="%Y%m"),
    old_id=tweets_draft$id,
    stringsAsFactors = FALSE
  )

# Token
token_quickbooks <- tweets["text"] %>%
  unnest_tokens(word, text) %>%
  anti_join(custom_stop_words) %>%
  count(word, sort=TRUE)

wordcloud(words = token_quickbooks$word,
          freq = token_quickbooks$n,
          min.freq = 1,
          max.words=200,
          random.order=FALSE,
          rot.per=0.35,
          colors=brewer.pal(8, "Dark2")
          )

# N-grams (n=2)
bigram_counts <- tweets["text"] %>%
  unnest_tokens(bigram, text, token="ngrams", n=2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% custom_stop_words$word) %>%
  filter(!word2 %in% custom_stop_words$word)  %>%
  count(word1, word2, sort = TRUE) %>%
  left_join(afinn, by=c(word1="word")) %>%
  left_join(afinn, by=c(word2="word"))

bigram_counts$value <- (ifelse(is.na(bigram_counts$value.x), 0, bigram_counts$value.x) + ifelse(is.na(bigram_counts$value.y), 0, bigram_counts$value.y)) * bigram_counts$n
bigram_counts <- bigram_counts[c("word1", "word2", "n", "value")]

# Graph of Negative Feelings
bigram_graph <- bigram_counts %>%
  filter(value<0) %>%
  #filter(n>1) %>%
  graph_from_data_frame()

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link()+
  geom_node_point()+
  geom_node_text(aes(label=name), vjust =1, hjust=1)

# Graph of Positive Feelings
bigram_graph <- bigram_counts %>%
  filter(value>0) %>%
  filter(n>2) %>%
  graph_from_data_frame()

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link()+
  geom_node_point()+
  geom_node_text(aes(label=name), vjust =1, hjust=1)

bigram_tf_idf <- tweets %>%
  unnest_tokens(bigram, text, token="ngrams", n=2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  #filter(!word1 %in% custom_stop_words$word) %>%
  #filter(!word2 %in% custom_stop_words$word)  %>%
  unite(bigram, word1, word2, sep=" ")  %>% #we need to unite what we split in the previous section
  count(id, bigram) %>%
  bind_tf_idf(bigram, id, n) %>%
  arrange(desc(tf_idf))

# N-grams (n=3)
trigram_counts <- tweets["text"] %>%
  unnest_tokens(trigram, text, token="ngrams", n=3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% custom_stop_words$word) %>%
  filter(!word2 %in% custom_stop_words$word) %>%
  filter(!word3 %in% custom_stop_words$word) %>%
  count(word1, word2, word3, sort = TRUE)

trigram_graph <- trigram_counts %>%
  filter(n>=8) %>%
  graph_from_data_frame()

ggraph(trigram_graph, layout = "fr") +
  geom_edge_link()+
  geom_node_point()+
  geom_node_text(aes(label=name), vjust =1, hjust=1)

trigram_tf_idf <- tweets %>%
  unnest_tokens(trigram, text, token="ngrams", n=3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  #filter(!word1 %in% custom_stop_words$word) %>%
  #filter(!word2 %in% custom_stop_words$word) %>%
  #filter(!word3 %in% custom_stop_words$word) %>%
  unite(trigram, word1, word2, word3, sep=" ")  %>% #we need to unite what we split in the previous section
  count(id, trigram) %>%
  bind_tf_idf(trigram, id, n) %>%
  arrange(desc(tf_idf))