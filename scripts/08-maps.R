# setup -------------------------------------------------------------------

rm(list = ls())

library(sf)
library(terra)
library(tmap)
library(tidyverse)

# data --------------------------------------------------------------------

#shapefiles

world <- 
  read_sf('shapefiles/world.gpkg') |> 
  st_make_valid() 

list.files(
  'shapefiles/processed',
  pattern = 'cou|usa',
  full.names = TRUE) |> 
  map(~ .x |> 
        read_sf()) |> 
  set_names(
    'counties',
    'usa') |>
  map(~ .x |> 
        st_transform(
          crs = st_crs(world))) |> 
  list2env(.GlobalEnv)

# rasters

list.files(
  'rasters/processed',
  pattern = '.tif$',
  full.names = TRUE) |> 
  map(
    ~ .x |> 
      rast()) |> 
  set_names(
    'elevation_usa', 
    'hillshade_usa') |> 
  list2env(.GlobalEnv)

my_species <-  
  'Pseudacris_crucifer'

occs <- 
  read_csv(
    paste0(
      'data/processed/final/',
      my_species,
      '_occs_clean.csv'))

occs_sf <- 
  occs |> 
  st_as_sf(
    coords = c(
      x = 'x',
      y = 'y'),
    crs = 4326) 

tm_shape(occs_sf) +
  tm_grid() +
  tm_dots(
    col = 'blue', 
    size = 0.2, 
    shape = 21)

# map 1 -------------------------------------------------------------------

tmap_mode('plot')

#tmap_mode('view')

pseudacris_usa <- 
  occs_sf |> 
  st_filter(usa)

pseudacris_usa_map <- 
  tm_shape(usa) +
  tm_grid(lines = FALSE) +
  tm_polygons() +
  tm_shape(pseudacris_usa) +
  tm_dots(
    col = 'blue', 
    size = 0.2, 
    shape = 21) +
  tm_scale_bar(
    text.size = 0.5,
    position = c('left', 'bottom'))

pseudacris_usa_map


# map 2 -------------------------------------------------------------------

indiana <- 
  usa |>
  filter(state == 'Indiana')

pseudacris_indiana_map <- 
  tm_shape(
    hillshade_usa %>%
      mask(indiana)) +
  tm_grid(lines = FALSE) +
  tm_raster(
    palette = gray(0:100 / 100),
    n = 100,
    legend.show = FALSE) +
  tm_shape(
    elevation_usa |>
      crop(indiana, mask = TRUE),
    raster.downsample = FALSE) +
  tm_raster(
    title = 'Elevation (m)',
    palette = terrain.colors(500),
    style = 'cont',
    alpha = 0.7) +
  tm_shape(
    indiana, is.master = T) +
  tm_borders() +
  tm_shape(
    occs_sf |> 
      st_filter(indiana)) +
  tm_dots(
    col = 'blue', 
    size = 0.2, 
    shape = 21) +
  tm_scale_bar(
    text.size = 0.5,
    breaks = c(0, 25, 50),
    position = c('right', 'bottom')) +
  tm_layout(
    legend.outside = TRUE)

pseudacris_indiana_map

# map 3 -------------------------------------------------------------------

tippecanoe <- 
  counties |> 
  filter(
    state == 'Indiana',
    name == 'Tippecanoe')

study_area <-  
  st_bbox(
    c(
      xmin = -87.5, 
      xmax = -86,
      ymin = 40,
      ymax = 41),
    crs = st_crs(world)) %>%  
  st_as_sfc()

pseudacris_tippecanoe_map <-
  usa |> 
  tm_shape(bb = study_area) +
  tm_grid(lines = FALSE) +
  tm_polygons('gray') +
  tm_shape(
    hillshade_usa %>%
      mask(indiana)) +
  tm_grid(lines = FALSE) +
  tm_raster(
    palette = gray(0:100 / 100),
    n = 100,
    legend.show = FALSE) +
  tm_shape(
    elevation_usa |>
      crop(indiana, mask = TRUE),
    raster.downsample = FALSE) +
  tm_raster(
    title = 'Elevation (m)',
    palette = terrain.colors(500),
    style = 'cont',
    alpha = 0.7) +
  tm_shape(indiana) +
  tm_borders() +
  tm_shape(
    counties |> 
      filter(state == 'Indiana')) +
  tm_borders() +
  tm_shape(tippecanoe) +
  tm_borders('red', lwd = 2) +
  tm_shape(
    occs_sf |> 
      st_filter(tippecanoe)) +
  tm_dots(
    'Source',
    col = 'source', 
    size = 0.2, 
    shape = 21) +
  tm_scale_bar(
    text.size = 0.5,
    position = c(0.05, 0.1),
    breaks = c(0, 10)) +
  tm_layout(
    legend.outside = TRUE)

pseudacris_tippecanoe_map

tmap_arrange(
  pseudacris_usa_map, 
  pseudacris_indiana_map,
  ncol = 1)

pseudacris_indiana_map_ab <- 
  tm_shape(
    indiana) +
  tm_borders() +
  tm_shape(
    counties |> 
      filter(state == 'Indiana')) +
  tm_polygons(
    col = 'aland',
    palette = 'Greens',
    n = 10) +
  tm_shape(
    occs_sf |> 
      st_filter(indiana)) +
  tm_dots(
    col = 'blue', 
    size = 0.2, 
    shape = 21) +
  tm_scale_bar(
    text.size = 0.5,
    breaks = c(0, 25, 50),
    position = c('right', 'bottom')) +
  tm_layout(
    legend.outside = TRUE)

pseudacris_indiana_map_ab

# try tmap_mode('view')

tmap_save(
  pseudacris_usa_map,
  filename = 'outputs/figures/pseudacris_usa_map.jpg',
  height = 7,
  width = 10,
  dpi = 400)

tmap_save(
  pseudacris_usa_map,
  filename = 'outputs/figures/pseudacris_usa_map.html')