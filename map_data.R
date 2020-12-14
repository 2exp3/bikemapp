library(leaflet);library(sp); library(tidyverse);library(leaflet.extras);library(htmltools);
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set wd to here
source("helpers.R",encoding = "UTF-8") # load auxiliary functions

# As a cyclist, what do I care about when I go on the road?
# - road surface (e.g. cobblestone, pavement)
# - bikelanes
# - parking spots (private or public)
# - water faucets
# - bike shops (in case of need to repair on the go)
# - gas stations (they have air pumps)

# although we have a good map for buenos aires city (https://www.buenosaires.gob.ar/ecobici/pedalea-la-ciudad),
# it lacks 2 main features: 
#  - no way to know which roads are bad for our precious bike (e.g. sett)
#  - no info at all outside Av General Paz (the city limit)

# It also doesn't have data on water faucets (but that is not *that* relevant)

# So, to solve this issue, I merged the official city data (gcba_data) with BBBike OpenStreetMap (OSM) data (osm_data),
# which -crucially- indexes road surfaces.
# Both files are preprocessed data from geojson and csv files from both sources

#  load data ====
load(file="data/osm_data.Rda") # BBBike OSM
load(file="data/gcba_data.Rda") # official

# Find possible duplicates ====
# It is likely that we have Point duplicates between the 2 databases.
# Lets check whether we find duplicates within a 50mtr radius for each type of spot (gas station, parking and bikeshops)
levels(puntos_df_fs$type)

aire_dup = duplis(puntos_df_fs, thresh=50, tipo="Aire", contra=aire_dff)
estac_dup = duplis(puntos_df_fs, thresh=10, tipo="Estacionamiento", contra=park_dff) #there might be parkings next to each other
taller_dup = duplis(puntos_df_fs, thresh=50, tipo="Taller", 
                    contra=data.frame(long=talleres_df@coords[,1],
                                      lat=talleres_df@coords[,2]) )

print(c(sum(aire_dup),sum(estac_dup), sum(taller_dup)))
sum(aire_dup&estac_dup&taller_dup) # non-redundant

# since the official db is less sparse, let's remove the duplicates from the OSM.
puntos_df_fsnd=puntos_df_fs[!(aire_dup|estac_dup|taller_dup),]

# merge DBs ====
# first, tidy a bit our OSM data 
names(puntos_df_fsnd)

puntos_df_fsnd$direccion=
  paste(puntos_df_fsnd$`addr:street`,puntos_df_fsnd$`addr:housenumber`) 


spots=
  data.frame(
    long=puntos_df_fsnd@coords[,1], 
    lat=puntos_df_fsnd@coords[,2],
    nombre=puntos_df_fsnd$name,
    direccion=puntos_df_fsnd$direccion,
    barrio=NA,
    localidad=puntos_df_fsnd$`addr:city`,
    tipo=puntos_df_fsnd$type,
    marca=puntos_df_fsnd$brand,
    operador=puntos_df_fsnd$operator,
    amenity=puntos_df_fsnd$amenity,
    shop=puntos_df_fsnd$shop,
    tarifa=puntos_df_fsnd$fee,
    tel=puntos_df_fsnd$phone,
    web=puntos_df_fsnd$website,
    horario=puntos_df_fsnd$opening_hours
  )

# now bind GCBA data

names(aire_dff) # keep long, lat, nombre, barrio, domicilio
aire_dff$direcc=""
for (d in 1:nrow(aire_dff)){
  spl=unlist(str_split(aire_dff$domicilio[d], pattern = ",") )
  aire_dff$direcc[d]=spl[1]
  }

spots_aire=
  with(aire_dff, 
  data.frame(
    long=long, lat=lat,nombre=nombre,
    direccion=direcc, barrio=barrio,
    localidad="CABA", tipo="Aire",
    marca=nombre, operador=razon_social,
    amenity=NA, shop=NA,tarifa=NA,tel=NA,web=NA,
    horario=NA
  ))


names(park_dff) # keep long, lat, nombre, barrio, ubicacion, (calle, altura)
park_dff$direccion=
  paste(park_dff$calle,park_dff$altura) 

spots_park=
  with(park_dff, 
       data.frame(
         long=long, lat=lat,nombre=nombre,
         direccion=direccion, barrio=barrio,
         localidad="CABA", tipo="Estacionamiento",
         marca=NA, operador=ubicacion,
         amenity=NA, shop=NA,tarifa=NA,tel=NA,web=NA,
         horario=NA
       ))


names(talleres_df) # keep long, lat, nombre, barrio, telefono, email, web, direccion, horario_de

spots_talleres=
  data.frame(
    long=talleres_df@coords[,1], 
    lat=talleres_df@coords[,2],
    nombre=talleres_df$nombre,
    direccion=talleres_df$direccion,
    barrio=talleres_df$barrio,
    localidad="CABA",  tipo="Taller",
    marca=NA, operador=NA,amenity=NA,  shop=NA,  tarifa=NA,
    tel=talleres_df$telefono,
    web=talleres_df$web,
    horario=talleres_df$horario_de
  )

spots_all=
  bind_rows(spots,
            spots_aire,
            spots_park,
            spots_talleres)


# generate html popups ====
bs_df_s$pop=""
for (ev in 1: nrow(bs_df_s)){bs_df_s@data[ev,]$pop = html_popup(bs_df_s@data[ev,], tipo="bs") }

ciclo_df$pop=""
for (ev in 1: nrow(ciclo_df)){ciclo_df@data[ev,]$pop = html_popup(ciclo_df@data[ev,], tipo="ciclovia") }

spots_all$pop=""
for (sp in 1:nrow(spots_all) ) {spots_all$pop[sp] = html_popup(spots_all[sp,], tipo="spot") }


# Make Icon List ====
IconSet=
  awesomeIconList(
    "Agua" = 
      makeAwesomeIcon(
        icon='glyphicon-tint',
        markerColor = 'blue',
        iconColor = 'white'),
    "Aire"= 
      makeAwesomeIcon(
        text = fontawesome::fa(name='gas-pump',fill = "white",height = 16),
        library = "fa",
        markerColor = 'orange',
        iconColor = 'white'),
    "Taller"=  
      makeAwesomeIcon(
        icon='glyphicon-wrench',
        markerColor = 'black',
        iconColor = 'white'),
    "Estacionamiento"=   
      makeAwesomeIcon(
        text = fontawesome::fa(name='parking',fill = "white",height = 16),
        library = "fa",
        markerColor = 'darkblue',
        iconColor = 'white')
  )

# keep only necessary info for each object
malas=bs_df_s[!bs_df_s$surface=="unpaved",c("surface","pop")]
ciclovias=ciclo_df[!str_detect(ciclo_df$tooltip_bi,"proyectada"),c("pop","tooltip_bi")]
lugares=spots_all %>% select(long,lat, pop, tipo)


# Ok, now we have all our data and groups, let's render a minimal pilot map to see the bad streets.

# A pilot map ====
leaflet(options = leafletOptions(preferCanvas = TRUE) ) %>% 
  # centered in beatiful CABA
  setView(lng = -58.44,lat = -34.62, zoom = 12) %>%
  # use gov map
  addWMSTiles(
    "https://servicios.usig.buenosaires.gob.ar/mapcache/tms/1.0.0/amba_con_transporte_3857@GoogleMapsCompatible/{z}/{x}/{-y}.png",
    options = WMSTileOptions(
      format = "image/png", transparent = TRUE,
      updateWhenZooming = FALSE,      # map won't update tiles until zoom is done
      updateWhenIdle = TRUE 
    ),
    layers = "nexrad-n0r-900913"
  ) %>% 
  # add bad streets
  addPolylines(
    data=malas,
    weight = 4.5,
    color="#fe4365",
    opacity = 1,
    noClip = T,
    smoothFactor = 5,
    group="bs",
    popup = ~pop
  ) 


# make distance-fixed polygons from lines ====
# this helps phone user to easily trigger popups from streets
malaspoly=line2poly(malas)
ciclopoly=line2poly(ciclovias)
 
# take a quick look ====
# leaflet() %>%
#   addTiles() %>%
#   addPolylines(data=malas, weight = 2,color="red") %>%
#   addPolygons(data=malaspoly,stroke = T,fill = T,smoothFactor = 3,noClip = T,
#               fillColor = "purple",fillOpacity = .75,weight = 0) %>%
#   addPolygons(data=ciclopoly,stroke = T,fill = T,smoothFactor = 3,noClip = T,
#               fillColor = "green",fillOpacity = .75,weight = 0,)
# # 

# save all====
# Now, a nice idea would be to have more control over which stuff we show.
# Luckily, we have the Shiny framework which nicely dovetails with Leaflet.
# We'll save our data and code our app (see "app/app.R")
save(file = "app/www/data_ciclista.Rda",
     IconSet,
     ciclovias,malas,lugares,
     malaspoly,ciclopoly)
