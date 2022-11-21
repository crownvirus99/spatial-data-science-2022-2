library(tidyverse)
#datos originales
direcciones <- read_csv2("data/mediciones.csv")
#datos para limpiar
d2 <- read_csv2("data/mediciones.csv")

#limpieza de direcciones: se borra todo lo que esta despues del numero de la direccion
d2$DIRECCION <- sub("^(\\D*\\d+).*", "\\1", direcciones$DIRECCION)
#limpieza de datos repetidos
d2 <- d2 %>% distinct()

dn <- d2 %>%
  separate(DIRECCION, 
           into = c("calle", "numero"), 
           sep = "(?<=[a-zA-Z])\\s*(?=[0-9])"
           )
dn <- dn %>% distinct(calle, .keep_all = TRUE)
dn$DIRECCION <- paste(dn$calle, dn$numero, sep=" ")
dn <- subset(dn, select = - c(calle, numero))
dn <- dn[, c(2,1)]

#20% datos al azar 
datos_random <- dn %>% sample_frac(0.2, replace = FALSE)

library(tidygeocoder)

coordenadas <- geo(datos_random$DIRECCION, method="osm") %>% as_tibble()
