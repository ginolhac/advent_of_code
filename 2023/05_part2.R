#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages(library(tidyverse))

input <- read_lines("05")

parse_map <- function(.data, type) {
  paste0(.data, collapse = "\n") |>
    str_extract(pattern = paste0(type, " map:\n([\\d\\s]*)"), group = 1) |>
    str_split_1("\n") |>
    str_subset("\\d+") |>
    map(\(x) {
      str_split_1(x, " ") |>
        as.numeric()
      # 1 is destination, 2 is origin and 3 is the length
    })
}

find_correspondences <- function(query, intervals) {
  for (rg in intervals) {
    if (query >= rg[2] & query <= (rg[2] + rg[3] - 1L)) {
      return(query + rg[1] - rg[2])
    }
  }
  query
}

fertilizer_types <- str_subset(input, "map") |>
  str_extract("\\w+\\-to\\-\\w+")

fertilizer_types |>
  set_names() |>
  map(\(x) parse_map(input, x)) -> garden_map

as.numeric(args[1]):as.numeric(args[2]) |>
  map_dbl(\(x) find_correspondences(x, garden_map$`seed-to-soil`), .progress = "soil") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`soil-to-fertilizer`), .progress = "fertilizer") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`fertilizer-to-water`), .progress = "water") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`water-to-light`), .progress = "light") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`light-to-temperature`), .progress = "temperature") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`temperature-to-humidity`), .progress = "humidity") |>
  map_dbl(\(x) find_correspondences(x, garden_map$`humidity-to-location`), .progress = "location") -> locations

saveRDS(locations, paste0("locations_", args[1], "-", args[2], ".rds"))

min(locations)
