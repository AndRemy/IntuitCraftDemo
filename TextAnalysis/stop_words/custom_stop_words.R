# Title     : TODO
# Objective : TODO
# Created by: Andre
# Created on: 6/4/2021

setwd("C:/Users/Andre/Documents/AndRemy/Sandbox/IntuitCraftDemo/")

data(stop_words)
custom_stop_words <- rbind(
  stop_words["word"],
  data.frame(
    word=c(
      "â",
      "ð",
      "ï",
      "iâ",
      "itâ",
      "âœ",
      "ðÿ",
      "canâ",
      "thatâ",
      "youâ",
      "donâ",
      "weâ",
      "ðÿœ",
      "hereâ",
      "00",
      "0",
      "1",
      "2",
      '3',
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "560",
      "800",
      "5139",
      "0792130809",
      "0789356550",
      "0716090961",
      "rt",
      "http",
      "https",
      "t.co",
      "amp",
      "9vrdw3w7t8",
      "bxg0qubers",
      "xw1k2xslij",
      "ss23gqnayh",
      "qglvdc5lg0",
      "0q01duewef",
      "6dlofjfydc",
      "bee21hlqdp",
      "0pegnwtmpx",
      "xqre6ivk6r",
      "yctdqpot73",
      "isryo1gdjw",
      "nh0ounuh78",
      "8hjex0tb8g",
      "al4wwgafm8",
      "iyibmxluyq",
      "bbxwvovqjj",
      "652ss50uxm",
      "czxsu8j4i6",
      "jkqfyiiatn",
      "m9xjkyk9qh",
      "g2xougzwav")
  )
)

write.csv(custom_stop_words, "custom_stop_words.csv")