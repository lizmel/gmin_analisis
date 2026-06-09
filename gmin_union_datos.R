
library(tidyverse)
library(ggplot2)

datos <- read.csv("conductancia_datos.csv")
traits <- read_csv("traits.csv",
                   col_types = cols(
                     id = col_character(),
                     peso_seco = col_double(),
                     AF = col_double(),
                     peso_saturado = col_double(),
                     tratamiento = col_character(),
                     poblacion = col_character()
                   ))
hobo <- read.csv("hobo.csv", skip=1) %>% 
  rename(
    datetime = 1,
    temp_C = 2,
    RH = 3
  )


datos <- datos %>%
  rename(
    id = 1,
    minutos = 2,
    dmasa = 3,
    masa = 4,
    hora = 5,
    fecha = 6
  )

hobo <- hobo %>%
  mutate(
    datetime = dmy_hm(datetime),
    temp_C = as.numeric(temp_C),
    RH = as.numeric(RH)
  )

datos_full <- datos %>%
  left_join(traits, by = "id")

datos_full <- datos_full %>%
  mutate(
    RWC = ((masa - peso_seco) / (peso_saturado - peso_seco))*100
  )

datos <- datos %>%
  mutate(
    datetime = as.POSIXct(paste(fecha, hora),
                          format = "%d/%m/%Y %H:%M")
  )


library(fuzzyjoin)

datos_clima <- difference_left_join(
  datos, hobo,
  by = "datetime",
  max_dist = 600   # 600 seg = 10 min
)
