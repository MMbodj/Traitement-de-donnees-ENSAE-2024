# This file is to run the pipeline one shot
pacman::p_load(
  stringr,
  here
)

# List of folders to run: add progressively
folders <- c(
  here("cleansurvey/1_data_exploration/1_get_initial_dict"),
  here("cleansurvey/1_data_exploration/2_select_and_label")
)

scripts <- list.files(
  folders,
  pattern = "\\.R$",
  full.names = TRUE,
  recursive = TRUE
)

stopifnot(length(scripts) > 0)

for (s in scripts) {
  message("▶ Running: ", s)
  system2("Rscript", c("--vanilla", shQuote(s)))
}

message("✅ All folders executed.")
