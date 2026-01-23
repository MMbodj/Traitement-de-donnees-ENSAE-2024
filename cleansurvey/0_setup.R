pacman::p_load(
  haven
)

# Read data from data folder
df <- read_dta(
  file.path("data/base_ehcvm2.dta")
)

str(df)


