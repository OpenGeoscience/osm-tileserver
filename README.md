# Standalone OpenStreetMap-Tileserver
This Vagrant Box's target is to provide a completely standalone, off-the-wire running map-server. The following components are being leveraged to provide this functionality:

* Ubuntu 14.04
* [Apache 2](https://httpd.apache.org/) with [mod_tile](https://github.com/openstreetmap/mod_tile) (mod_tile is compiled from latest master on provision)
* [renderd](https://github.com/openstreetmap/mod_tile) (compiled from latest master on provision)
* [Mapnik](https://github.com/mapnik/mapnik) (currently locked on 2.2.x branch due to compat issues)
* [PostgreSQL 9.3](https://www.postgresql.org/)
* [osm2pgsql](https://github.com/openstreetmap/osm2pgsql) (compiled from latest master on provision)

The maps are rendered using [osm-bright](https://github.com/mapbox/osm-bright), GIS data is imported from the [Swiss OpenStreetMap Association](http://www.osm.ch/) (using the latest data for [California](http://download.geofabrik.de/north-america/us/california-latest.osm.pbf), downloaded on provision). The setup is based on [this article](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/).

It is HIGHLY advised to setup the box on a fast SSD disk (due to the high I/O throughput required for the GIS-data import). The disk space required on the server is about 15 GB (depends on the amount of tiles that are rendered).

When changing the memory settings for the box, don't forget to adapt the cache-setting for the osm2pgsql call (L112 in `vagrant\Vagrantfile`). It should be half the value of the memory space allocated.

## Usage
1. Make sure you have the latest versions of both [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installed.
2. Clone or download the repository.
3. Open a shell/command line and `cd` to `vagrant`
4. Run `vagrant up`
5. Wait until provisioning is finished (**depending on your internet connection/host performance, this can take up to several hours!**).
6. Fire up a browser and open `http://localhost:8080/` to open a Leaflet interface connected to your new tileserver.

## Docker

Create a postgis database.

Clone this repository.
```
git clone https://github.com/OpenGeoscience/osm-tileserver.git
cd osm-tileserver
```

Change the .env file.
```
export PG_HOST=127.0.0.1    # Postgis host
export PG_PORT=5432    # Postgis port
export PG_DB=gis    # Postgis database
export PG_USER=postgis    # Postgis user
export PG_PASSWORD=letmein    # Postgis password
export PBF_URL=http://download.geofabrik.de/europe/cyprus-latest.osm.pbf    # pbf file url (http://download.geofabrik.de/)
export CACHE=4096    # Set this to 75% of the memory that machine has
export NUM_PROCESSES=4    # Number of cores
export PORT=9000    # Port for tile server to be up and running
export TILE_CACHE_DIR=/tmp/mod_tile    # Cache directory on the host computer

```

Source the env file.
```
source .env
```

Do the ingest.
```
make ingest
```

Start serving tiles.
```
make serve
```

After the containers are up, precache tiles.
```
make cache-tiles
```
