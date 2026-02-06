# This file contains useful general functions
pacman::p_load(
  dplyr
  )

# Function to pply a data dict to a dataframe (renaming, relabelliing, type setting)
apply_var_dictionary <- function(df, dict) {

  stopifnot(all(c("var_orig", "var_new", "type_new", "keep") %in% names(dict)))

  dict <- dict %>%
    filter(var_orig %in% names(df))

  rename_map <- setNames(dict$var_orig, dict$var_new)

  df <- df %>%
    rename(!!!rename_map)

  label_map <- setNames(dict$label_new, dict$var_new)

  for (v in intersect(names(df), names(label_map))) {
    attr(df[[v]], "label") <- label_map[[v]]
  }

  for (i in seq_len(nrow(dict))) {
    v <- dict$var_new[i]
    t <- dict$type_new[i]

    if (!v %in% names(df)) next

    if (t == "factor") {
      df[[v]] <- haven::as_factor(df[[v]], levels = "labels")
    } else if (t == "numeric") {
      df[[v]] <- as.numeric(df[[v]])
    } else if (t == "character") {
      df[[v]] <- as.character(df[[v]])
    }
  }

  vars_keep <- dict %>%
    filter(tolower(keep) == "yes") %>%
    pull(var_new)

  df %>%
    select(any_of(vars_keep))
}

# Function to pply a modality dict to a dataframe (modality labeling)
apply_modality_dictionary <- function(df, dict) {

  vars_to_recode <- intersect(names(df), unique(dict$var_name))

  df %>%
    mutate(
      across(
        all_of(vars_to_recode),
        ~ {
          if (!is.factor(.x)) return(.x)

          d <- dict %>% filter(var_name == cur_column())
          if (nrow(d) == 0) return(.x)

          fct_relabel(
            .x,
            function(lvls) {
              idx <- match(lvls, d$label_init)
              ifelse(
                is.na(idx),
                lvls,
                d$label_new[idx]
              )
            }
          )
        }
      )
    )
}
