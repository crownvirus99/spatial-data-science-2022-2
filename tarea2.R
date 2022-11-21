library(tidyverse)

#datos originales
direcciones <- read_csv2("data/mediciones.csv")
#datos para limpiar
d2 <- read_csv2("data/mediciones.csv")

#limpieza de direcciones: se borra todo lo que esta despues del numero de la direccion
d2$DIRECCION <- sub("^(\\D*\\d+).*", "\\1", direcciones$DIRECCION)
#limpieza de datos repetidos
d2 <- d2 %>% distinct()

#se borran calles repetidas (sin contar el numero de la direccion) para tener menos datos
dn <- d2 %>%
  separate(DIRECCION, 
           into = c("calle", "numero"), 
           sep = "(?<=[a-zA-Z])\\s*(?=[0-9])"
           )
dn <- dn %>% distinct(calle, .keep_all = TRUE)
dn$DIRECCION <- paste(dn$calle, dn$numero, sep=" ")
dn <- subset(dn, select = - c(calle, numero))
dn <- dn[, c(2,1)]

#muestra de 15% de los datos al azar 
datos_random <- dn %>% sample_frac(0.15, replace = FALSE)

library(tidygeocoder)

#coordenadas de las direcciones (15%)
coordenadas <- geo(datos_random$DIRECCION, method="arcgis") %>% as_tibble()

write.csv(coordenadas,"coordenadas_direcciones.csv", row.names = FALSE)
