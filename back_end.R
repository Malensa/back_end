
#* @get /get_table
#* @param foodlink
#* @response  table output

#packages to load
install.packages("rvest")
install.packages("RPostgres")
install.packages("stringr")
install.packages("tidyverse")
install.packages("DBI")
library(readr)
library(rvest)
library(stringr)
library(tidyverse)
library(data.table)
library(DBI)

#open connection
ip <- "35.228.50.60"
db_name <- "postgres"
user <- ""
pwd <- ""

#Connection Setup
db <- DBI::dbConnect(RPostgres::Postgres(),
                     dbname = db_name,
                     host = ip,
                     port = 5432,
                     user = user,
                     password = pwd)

#load tables
emissions_data <- data.table(dbReadTable(db, "emissions"))
cooking_vocab_data <- data.table(dbReadTable(db, "cooking_vocabulary"))
cooking_units_data <- data.table(dbReadTable(db, "cooking_units"))
plurals_en <- data.table(dbReadTable(db, "plurals_en"))
recipes_data <- data.table(dbReadTable(db, "recipes_table"))
synonyms_data <- data.table(dbReadTable(db, "synonyms_en"))

#link
link <- read_html("https://www.food.com/recipe/club-wrap-222855")

#raw scrape - Quantity
ing_quant <- link %>%
  html_nodes(".ingredient-quantity") %>%
  html_text() %>%
  trimws(which = "both") %>%
  data.frame() 

#raw scrape - Ingredient
ing_name <- link %>%
  html_nodes(".ingredient-text") %>%
  html_text() %>%
  trimws(which = "both") %>%
  data.frame()

#Clean the quantity
ing_quant <- ing_quant %>%
  rename("Quantity" = ".")

#Separate the measurements
ing_name <- ing_name %>%
  rename("Ingredient" = ".")
x <- 1
for (row in ing_name$Ingredient) {
  
  measur <- str_extract(row, "(\\w+)")
  
  if ((measur %in% cooking_units_data$unit) == TRUE) {
    
    ing_name$Measurement[x] <- measur
    ing_name$Ingredient[x] <- str_remove(ing_name$Ingredient[x], measur)
    
  } else {
    
    ing_name$Measurement[x] <- 1
    
  }
  
 x <- x + 1
   
}

#White spaces
ing_name$Ingredient <- ing_name$Ingredient %>%
  trimws(which = "both")

#add emissions
x <- 1
for (row in ing_name$Ingredient) {
  
  if ((row %in% emissions_data$ingredient) == TRUE) {
    
    print(row)
    ing_name$CO2[x] <- emissions_data %>%
      filter(ingredient == row) %>%
      select(emissions)
    
  } else {
    
    ing_name$CO2[x] <- 0
    
  }
  x <- x + 1
}

#standardize

#retrieve data

#calculation


