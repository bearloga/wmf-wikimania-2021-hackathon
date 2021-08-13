install.packages(c(
    "fs",
    "here",
    "tidyverse"
))

here::i_am("setup.R")

library(fs)
library(here)

dir_create(here("data"))
dir_create(here("scripts"))
dir_create(here("scratch"))
