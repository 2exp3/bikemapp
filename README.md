# Bikemapp 

 I live in a city -[Buenos Aires](https://en.wikipedia.org/wiki/Buenos_Aires)- that has many *uneven* roads (e.g. sett and cobblestone roads) which make riding a bike a bit more of a hazard (for me and for my bike).
 
 Importantly, although we have an [official city map](https://mapa.buenosaires.gob.ar/v4/mapas/?lat=-34.620000&lng=-58.440000&zl=12&modo=transporte&map=red_de_ciclovias), we lack a map that indexes these bad streets. 
 
 So, I decided to draw on this idea of a **map for cyclists**, and make a more general tool that provides information on the main things cyclists usually need to know when riding on the city (e.g. water faucets, bikeshops).

 By combining data taken from the excellent [OpenStreetMap (OSM) collaborative project](https://download.bbbike.org/osm/bbbike/BuenosAires/) and from our [government databases](https://usig.buenosaires.gob.ar/) (which is less sparse and better curated, but limited to the federal district) I aimed to deliver a tool for all [metropolitan-area](https://es.wikipedia.org/wiki/Gran_Buenos_Aires#Regi%C3%B3n_Metropolitana_de_Buenos_Aires_(RMBA)) cylists.

From a more technical standpoint, I created spatial (lines, markers, circles and polygons) data objects (with the [`sp`](https://cran.r-project.org/web/packages/sp/index.html) and [`sf`](https://cran.r-project.org/web/packages/sf/index.html) packages) that I fed to a [leaflet](https://cran.r-project.org/web/packages/leaflet/index.html) map, which reacts to user interactions using the [R-Shiny](https://cran.r-project.org/web/packages/shiny/index.html) framework with [Framework7](https://framework7.io/) standalone capabilities -via [shinyMobile](https://cran.r-project.org/web/packages/shinyMobile/index.html)- which ensures functionality across mobile devices.

You may try the (bikem)app:

<p align="center">
   <a href="https://2exp3.shinyapps.io/mapa-ciclista/">HERE</a> 
</p>

*Note: for obvious reasons, all text is in Spanish*.

Finally, I hope this project further encourages us all to [participate in OSM](https://wiki.openstreetmap.org/wiki/Beginners%27_guide) to not only make this map more accurate and complete, but also to aid many other projects that rely on these data.


# Mapa del Ciclista

Vivo en una ciudad -[Buenos Aires](https://es.wikipedia.org/wiki/Buenos_Aires)- que tiene varias calles *complicadas* (por ej, empedradas, adoquinadas), lo que hace que andar en bici sea un poco peligroso (para mí y para mi bici).
 
 A pesar de que tenemos un [mapa oficial de la ciudad (CABA)](https://mapa.buenosaires.gob.ar/v4/mapas/?lat=-34.620000&lng=-58.440000&zl=12&modo=transporte&map=red_de_ciclovias), no tenemos un mapa donde podamos ver cuáles son esas calles con superficie mala.
 
 Por esto, decidí tomar esta idea de un **mapa del ciclista** para expandirla a una herramienta más general que ofrezca información sobre las cosas que los ciclistas generalmente necesitamos saber cuando andamos por la ciudad (por ej, dónde hay para cargar agua o arreglar la cámara por si pinchamos).

Con datos del excelente [proyecto colaborativo OpenStreetMap (OSM)](https://download.bbbike.org/osm/bbbike/BuenosAires/) y del [sitio oficial de bases de datos del gobierno de CABA](https://usig.buenosaires.gob.ar/)
(que es bastante más completo y mejor curado, aunque limitado exclusivamente a CABA, obviamente) apunté a proveer una herramienta para los ciclistas de todo el [area metropolitana (AMBA)](https://es.wikipedia.org/wiki/Gran_Buenos_Aires#Regi%C3%B3n_Metropolitana_de_Buenos_Aires_(RMBA)).

Desde un punto de vista técnico, con estos datos generé objetos que representan datos espaciales (líneas, marcadores, círculos y polígonos) con los paquetes [`sp`](https://cran.r-project.org/web/packages/sp/index.html) y [`sf`](https://cran.r-project.org/web/packages/sf/index.html). Con estos objetos, alimenté un mapa generado en [leaflet](https://cran.r-project.org/web/packages/leaflet/index.html) que reacciona a interacciones del usuario usando [R-Shiny](https://cran.r-project.org/web/packages/shiny/index.html) con capacidades de [Framework7](https://framework7.io/)-via [shinyMobile](https://cran.r-project.org/web/packages/shinyMobile/index.html)- que asegura funcionalidad en dispositivos móviles.

Podés probar el mapa:

<p align="center">
   <a href="https://2exp3.shinyapps.io/mapa-ciclista/">ACA</a> 
</p>

Por último, espero que este proyecto nos aliente a [participar como editores en OSM](https://wiki.openstreetmap.org/wiki/ES:Gu%C3%ADa_de_principiantes) no sólo para hacer que este mapa sea más preciso y completo, sino también para ayudar a otros proyectos que recurren a estos datos.

¡Que lo disfruten!

<h3 align="center">
Con la bici, a todos lados.
</h3>
