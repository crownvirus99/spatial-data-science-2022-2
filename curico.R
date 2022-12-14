pacman::p_load(tidyverse, rgee, sf, raster) 

ee_Initialize(drive = T)

# defino una region de interes ----
roi <- 
  c(-71.241178, -34.984744) %>%  # laguna aculeo
  st_point(dim = "XYZ") %>% 
  st_buffer(dist = 0.2) %>% 
  sf_as_ee()
# 

# indices espectrales ----

# llamo funciones
source("R/indices.R")

# listo funciones
funs <- lsf.str()

for(i in 1:length(funs)){
  png(file=paste0("Figuras/",funs[i],"_plot.png"), width=500, height=600)
  plot(do.call(funs[i], list(l8_img)))
  dev.off()
}

# analisis aculeo en el tiempo ----
analisis_aculeo <- function(anio){
  disponible <- ee$ImageCollection('LANDSAT/LC08/C01/T1_TOA')$
    filterDate(paste0(anio,'-01-01'),paste0(anio,'-04-30'))$
    filterBounds(roi)$
    filterMetadata('CLOUD_COVER','less_than', 10)
  
  df_disponible <- ee_get_date_ic(disponible)%>%
    arrange(time_start)
  
  # extraigo la primera
  escena <- df_disponible$id[1]
  
  # defino las bandas que me interesa extraer para el NDWI
  l8_bands <- ee$Image(escena)$select(c("B2", "B3", "B4", "B5"))
  # B1: Aerosol, B2: Blue, B3: Green, B4: Red
  # B5: NIR, B6: SWIR 1, B7: SWIR 2, B9: Cirrus
  
  # extraigo imagenes satelitales 
  l8_img <- ee_as_raster(
    image = l8_bands,
    region = roi$bounds(),
    scale = 30)
  
  # extraigo valores de vegetacion
  veg <- calc(NVDI(l8_img), fun = function(x) ifelse(x <= 0.2, NA, x))
  
  # guardo plot
  png(file=paste0("Figuras/maule_anio",anio,".png"), width=500, height=600)
  plotRGB(l8_img, r=3, g=2, b=1, stretch = "lin")
  plot(veg, add = TRUE)
  dev.off()
}

analisis_aculeo(2021)

purrr::map(2013:2021, analisis_aculeo)

