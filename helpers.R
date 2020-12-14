
# HTML popup ====

html_popup=function(lugar, tipo){
  tit_center = "<div style='text-align:center; font-size: medium;'>"
  
  if (tipo=="ciclovia"){
    nom_calle = paste0("<b>Calle: </b>", lugar$nom_mapa,"<br>")
    barrio =  ifelse(is.na(lugar$BARRIO),"", paste0("<b>Barrio: </b>", lugar$BARRIO,"<br>") )
    tooltip = paste0("<b>Tipo: </b>", lugar$tooltip_bi,"<br>")
    lado_ciclo = ifelse(is.na(lugar$lado_ciclo),"",paste0("<b>Lado: </b>", lugar$lado_ciclo,"<br>") )
    
    popup=paste0(nom_calle,barrio,tooltip,lado_ciclo)
    
  }else if(tipo=="bs"){
    nom_calle = ifelse(is.na(lugar$name),"Sin nombre<br>",paste0("<b>Calle: </b>", lugar$name,"<br>"))
    superficie = paste0("<b>Tipo: </b>", traducir(lugar$surface),"<br>")
    
    popup=paste0(nom_calle, superficie)
    
  }else if(tipo=="spot"){
    
    if(lugar$tipo=="Agua"){
      popup="<div style='text-align: center;font-size: medium;'>Agua</div>"
      
    }else if(lugar$tipo=="Aire"){
      nombre =  paste0(tit_center,ifelse(is.na(lugar$marca),"Sin nombre</div> <br>",paste0("<b>",lugar$marca,"</b></div><br>" )  ) )
      direccion = ifelse(str_detect(lugar$direccion, "NA"),"",paste0("<b>Direccion: </b>", lugar$direccion,"<br>") )
      barrio = ifelse(is.na(lugar$barrio),"", paste0("<b>Barrio: </b>", lugar$barrio,"<br>") )
      localidad = ifelse(is.na(lugar$localidad),"",paste0("<b>Localidad: </b>", lugar$localidad,"<br>") )
      horario = ifelse(is.na(lugar$horario),"", paste0("<b>Horario: </b>", lugar$horario,"<br>") )
      
      popup=paste0(nombre,direccion,barrio,localidad,horario)
      
    }else if(lugar$tipo=="Estacionamiento"){
      nombre = paste0(tit_center,ifelse(is.na(lugar$nombre),"Sin nombre</div> <br>",paste0("<b>",gsub('[^ -~]', '',lugar$nombre),"</b></div><br>" )  ) )
      operador = ifelse(is.na(lugar$operador),"", paste0("<b>Tipo: </b>", lugar$operador,"<br>") )
      direccion = ifelse(str_detect(lugar$direccion, "NA"),"",paste0("<b>Direccion: </b>", lugar$direccion,"<br>") )
      barrio = ifelse(is.na(lugar$barrio),"", paste0("<b>Barrio: </b>", lugar$barrio,"<br>") )
      localidad = ifelse(is.na(lugar$localidad),"",paste0("<b>Localidad: </b>", lugar$localidad,"<br>") )
      horario = ifelse(is.na(lugar$horario),"", paste0("<b>Horario: </b>", lugar$horario,"<br>") )
      
      popup=paste0(nombre,operador,direccion,barrio,localidad,horario)
      
     }else if(lugar$tipo=="Taller"){
       nombre = paste0(tit_center,ifelse(
         is.na(lugar$nombre),"Sin nombre</div><br>",
         ifelse(
           is.na(lugar$web),
           paste0("<b>",lugar$nombre,"</b></div><br>" ),
           ifelse(
             str_detect(lugar$web,"http"),
             paste0("<a href='",lugar$web,"' target='_blank'  >", lugar$nombre, "</a></div><br>"),
             paste0("<a href='https://",lugar$web,"' target='_blank' >", lugar$nombre, "</a></div><br>")
           )
         )
       )
       )
       direccion = ifelse(str_detect(lugar$direccion, "NA"),"",paste0("<b>Direccion: </b>", lugar$direccion,"<br>") )
       barrio = ifelse(is.na(lugar$localidad),"", 
                       ifelse(is.na(lugar$barrio), "", paste0("<b>Barrio: </b>", lugar$barrio,"<br>") ) ) 
       localidad = ifelse(is.na(lugar$localidad),"",paste0("<b>Localidad: </b>", lugar$localidad,"<br>") )
       horario = ifelse(is.na(lugar$horario),"", paste0("<b>Horario: </b>", lugar$horario,"<br>") )

       popup=paste0(nombre,direccion,barrio,localidad,horario)
     }
    
  }
  return(popup)
}



traducir=function(palabra){
  # Sett paving, formed from natural stones cut to a regular shape
  if(tolower(palabra)=="sett"){return("Adoquinado")}
  # self explanatory
  if(tolower(palabra)=="unpaved"){return("Sin pavimentar")}
  # Generic value for cobblestone in the colloquial sense (includes sett)
  if(tolower(palabra)=="cobblestone"){return("Empredrado")}
  # Crushed stone used to build roads and highways, to make concrete, etc.
  if(tolower(palabra)=="gravel"|tolower(palabra)=="fine_gravel"){return("Ripio")}
  # Surface that consists of loose rounded medium sized stones
  if(tolower(palabra)=="pebblestone"){return("Ripio")}
}




# To detect duplicates ====

dist_latlong=function (lat1,lon1,lat2,lon2) {
  R = 6371 # Radius of the earth in km
  dLat = deg2rad(lat2-lat1)  # deg2rad below
  dLon = deg2rad(lon2-lon1)
  
  # use Haversine formula
  a = 
    sin(dLat/2) * sin(dLat/2) +
    cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * 
    sin(dLon/2) * sin(dLon/2)
  
  c = 2 * atan2(sqrt(a), sqrt(1-a))
  d = R * c * 1000 # Distance in meters
  return (d)
}

deg2rad=function (deg) {
  return (deg * (pi/180))
}


# to detect duplicates
duplis=function(puntos, thresh=50, tipo="Aire", contra){
  comp=which(puntos@data$type==tipo)
  dupli=rep(F, nrow(puntos))
  
  for (i in comp){
    distancia=dist_latlong(puntos@coords[i,1],puntos@coords[i,2],contra$long,contra$lat)
    
    if (min(distancia)<thresh){
      dupli[i] = T
    }
  }
  return(dupli)
}


# kinda a lot of work just to make line width not in pixels but in distance :/
line2poly=function(lines,width=.0001){
  # get list of  line coords and IDs
  linecoords = get_line_coords(lines) 
  lineids = get_line_ids(lines)
  
  # get list of lines edges
  edges = get_line_edges(linecoords)
  
  # make list of poly of given width to the sides, for each line
  polycoords=list()
  for (i in 1: length(edges)){
    polycoords[[i]]=lapply(edges[[i]],make_poly, width)
  }
  # to spatial format (Polygon in Polygons in SpatialPolygons)
  myPolygonList=list()
  myPolygons=list()
  for (i in 1: length(polycoords)){
    myPolygonList[[i]]=
      lapply(polycoords[[i]],sp::Polygon, hole=F)
    
    myPolygons[[i]]=
      sp::Polygons(myPolygonList[[i]], ID=lineids[[i]])
    
  }
  return(myPolygons)
}



get_line_coords=function(lines){
  linecoords=
    lapply(
      lapply(lines@lines, function(x) return(x@Lines[[1]])),
      function(x)return(x@coords)
    ) 
  return(linecoords)
}

get_line_ids=function(lines){
  lineids=lapply(lines@lines, function(x) return(x@ID) )
  return(lineids)
}

get_line_edges=function(linecoords){
  edgesid =
    lapply(linecoords, function(x){
      edges=list()
      for (i in 1:(nrow(x)-1) ){
        ini=x[i,]
        last=x[i+1,]
        edges[[i]]=rbind(ini, last)
      }
      return(edges)
    }
    )  
  return(edgesid)
}

make_poly=function(edges, offs){
  # distance of last to ini edge
  deltas=edges[2,]-edges[1,]
  # first col is LONG, second is LAT
  tita=atan(deltas[2]/deltas[1]) #dlat/dlong
  
  # get 90deg displacements (on long and lat axes) of desired r(offs), using trigonometric fns
  dlong=cos( tita +(pi/2) )*offs
  dlat=sin( tita+(pi/2) )*offs
  
  # displace edges by those deltas to make a rectangular poly
  poly=
    rbind(
      c(edges[1,1]-dlong,edges[1,2]-dlat),
      c(edges[1,1]+dlong,edges[1,2]+dlat),
      c(edges[2,1]+dlong,edges[2,2]+dlat),
      c(edges[2,1]-dlong,edges[2,2]-dlat),
      c(edges[1,1]-dlong,edges[1,2]-dlat) # close the poly
    )
  
  return(poly)
}
