rm(list = ls())
gc()

pacman::p_load(
  haven,
  readr,
  labelled,
  purrr,
  tibble,
  readxl,
  data.table
)

# Call sources
source("cleansurvey/config.R")
source("cleansurvey/utils.R")

table_obj = "ind"

# Read data from data folder
df <- read_dta(
  file.path(MAIN_DATA_PATH,
            paste("ehcvm2_", table_obj, ".dta", sep = ""))
)

# Get data dictionnary
dict_filled <- read_excel(
  file.path(
    AUX_FILE_PATH,
    paste("dictionary_", table_obj, "_filled.xlsx", sep = ""))
) |>
  mutate(
    keep = tolower(keep),
    type_new = tolower(type_new)
  )

# Quick check : alignment between init and filled dict
dict_init <- read.csv(
  file.path(
    AUX_FILE_PATH,
    paste("dictionary_", table_obj, "_init.csv", sep = ""))
)

out <- setdiff(unique(dict_init$var_orig), unique(dict_filled$var_orig))

# Applying data dict to individus
if (length(out) != 0) {
  message("Data dictionnary initial different from Data dictionnary filled.")
} else {

  # Apply dictionnary changes to individus
  df_renamed <- apply_var_dictionary(
    df   = df,
    dict = dict_filled
  )
  # Get variable modalities to build a modality dictionary
  mod_dict_init <- map_dfr(
    names(df_renamed),
    function(v) {
      x <- df_renamed[[v]]

      if (is.factor(x) && !is.null(levels(x))) {
        tibble(
          var_name   = v,
          label_init = levels(x) 
        )
      }
    }
  )

  fwrite(
    mod_dict_init,
    file.path(
      AUX_FILE_PATH,
      paste("dictionary_modality_", table_obj, "_init.csv", sep = ""))
  )

  fwrite(
    df_renamed,
    file.path(
      MAIN_DATA_PATH,
      paste("ehcvm2_", table_obj, "_renamed.csv", sep = ""))
  )

  message("Data dictionnary applied and modality dictionnary saved. Need manual processing to complete the modality dictionnary.")
}

