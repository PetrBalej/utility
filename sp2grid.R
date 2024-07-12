# working directory
wd <- "C:/Users/petr/Documents/sp2grid/"

# grid SHP path
grid.file <- paste0(wd, "data/sitmap_0rad.shp")

# occurrences SHP path
occs.file <- paste0(wd, "data/ndop_export.shp")

# species column name
occs.species <- "export_DRU"

########################################################################

library(sf)
library(tidyverse)
library(magrittr)

grid.shp <- st_read(grid.file)
grid.crs <- st_crs(grid.shp)
if(is.na(grid.crs)){
  print("CRS grid SHP not set!")
  print(grid.crs)
  stop()
}

occs.shp <- st_read(occs.file)
occs.crs <- st_crs(occs.shp)
if(is.na(occs.crs)){
  print("CRS occs SHP not set!")
  print(occs.crs)
  stop()
}

if(grid.crs != occs.crs){
  print("set grid CRS to occs if not equal")
  occs.shp <- st_transform(occs.shp, grid.crs)
}


grid.shp %<>% mutate(rid = row_number()) 
occs.shp %<>% mutate(rid = row_number()) 

gridXoccs <- st_intersects(occs.shp, grid.shp)

occs.shp %<>% mutate(rid_grid = NA)

gridXoccs <- lapply(gridXoccs, function(o){ ifelse(length(o) > 0, o, NA) })

occs.shp$rid_grid <- unlist(gridXoccs)


if(sum(is.na(occs.shp$rid_grid)) > 0){
  # check points out of grid
  print("occs out of grid (removed):")
  print(occs.shp %>% filter(is.na(rid_grid)))
  # remove points from SHP
  occs.shp %<>% filter(!is.na(rid_grid))
}

occs.stats <-  as_tibble(occs.shp) %>% group_by(rid_grid) %>% 
  mutate(speciesCount = n_distinct(!!sym(occs.species))) %>% 
  mutate(speciesNames = paste(sort(unique(!!sym(occs.species))), collapse=",")) %>% 
  slice_head() %>% ungroup() %>% dplyr::select(speciesCount, speciesNames, rid_grid, -geometry)


grid.shp %<>% left_join(occs.stats, by = c("rid"="rid_grid"))


st_write(grid.shp, paste0(wd,"grid_stats.shp"))


# count cells with identical counts
grid.cellsStats <-  as_tibble(grid.shp) %>% ungroup() %>% group_by(speciesCount) %>% 
  mutate(cellsCount = n()) %>% 
  mutate(cellsPct =  cellsCount * 100 / nrow(grid.shp)) %>% 
  slice_head() %>% ungroup() %>% 
  dplyr::select(cellsCount, speciesCount, cellsPct, -geometry)

write_csv(grid.cellsStats, paste0(wd, "grid_cellStats.csv"))
