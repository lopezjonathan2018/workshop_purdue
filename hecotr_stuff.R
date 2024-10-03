
# setup -------------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(rgbif)
library(sf)
install.packages("janitor")
install.packages("sf")
install.packages("rgbif")

# data --------------------------------------------------------------------

my_species <- 'Pseudacris_crucifer'

key <- 
  name_backbone(my_species) |>
  pull(usageKey)

usa <- 
  read_sf('shapefiles/cb_2018_us_state_500k.shp') |>
  st_make_valid() |>
  janitor::clean_names()

usa |>
  write_sf('shape')


rgbif_download <- 
  occ_download(
    pred('taxonKey', key),
    format = 'SIMPLE_CSV',
    user = 'lopezjonathan2018',
    pwd = 'Cps44008262!',
    email = 'lopezjonathan2018@gmail.com')

rgbif_download

#rgbif_download |> 
  #write_rds(
   # paste0(
      #'data/raw',
      #my_species,
      #'_key.rds'))
      #'
      #'
data <- 
  occ_download_get(
    rgbif_download,
    path = 'data/raw',
    overwrite = TRUE) |>
  occ_download_import()
#use