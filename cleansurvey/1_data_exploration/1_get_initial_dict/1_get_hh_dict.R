rm(list = ls())
gc()

pacman::p_load(
  haven,
  tibble,
  dplyr,
  labelled,
  data.table
)

# Call sources
source("cleansurvey/config.R")

table_obj = "hh"

# Read data from data folder
df <- read_dta(
  file.path(MAIN_DATA_PATH,
            paste("ehcvm2_", table_obj, ".dta", sep = ""))
)

# Get variable list with label and factor to build a data dictionary
dict_init <- tibble(
  var_orig = names(df),
  label_orig = sapply(df, function(x) {
    if (!is.null(var_label(x))) var_label(x) else NA_character_
  }),
  type = sapply(df, function(x) {
    if (inherits(x, "labelled")) "labelled"
    else if (is.factor(x)) "factor"
    else if (is.character(x)) "character"
    else if (is.numeric(x)) "numeric"
    else class(x)[1]
  })
)

fwrite(
  dict_init,
  file.path(
    AUX_FILE_PATH,
    paste("dictionary_", table_obj, "_init.csv", sep = ""))
)

message("Initial data dictionnary saved. Need manual processing to complete the data dictionnary.")




