# R libs raster vs. terra: coords from raster extraction comparison (400t points over Czechia, raster NDVI 3km px; WS2)

library(microbenchmark)
library(raster)
library(terra)

r.raster <- "xxx"
r.terra <- terra::rast(r.raster)

p.raster <- sf::st_coordinates("xxx")
p.terra <- vect(p.raster)

result <- microbenchmark(
  raster::extract(r.raster, p.raster, cellnumbers = TRUE),
  terra::extract(r.terra, p.terra,  cells=TRUE),
  times = 10
)
print(result)

# Unit: milliseconds
#                                                     expr       min        lq      mean    median        uq       max neval
#  raster::extract(r.raster, p.raster, cellnumbers = TRUE) 2127.8575 2208.2823 2307.3645 2248.5908 2436.7655 2549.2198    10
#           terra::extract(r.terra, p.terra, cells = TRUE)  797.5675  843.5569  883.0202  890.7006  910.0651  947.4068    10

# terra 2.5 times faster than raster
