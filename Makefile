test_db:
	createdb -E UTF8 -O ${PG_USER} ${PG_DB}
	psql -d ${PG_DB} -c "CREATE EXTENSION postgis;"
	psql -d ${PG_DB} -c "CREATE EXTENSION hstore;"
	echo "ALTER USER ${PG_USER} WITH PASSWORD '${PG_PASSWORD}';" | psql -d ${PG_DB}

ingest:
	docker build --file Dockerfile.osm2pgsql --build-arg PBF_URL=${PBF_URL} -t osm2pgsql .
	docker run --net=host -it --rm osm2pgsql -c "osm2pgsql --slim --hstore \
		--database ${PG_DB} \
		--host ${PG_HOST} \
		--username ${PG_USER} \
		--cache ${CACHE_RAM} \
		--number-processes ${NUM_PROCESSES} \
		pbf/planet.osm.pbf"

serve:
	sed -i "/\"host\"/c\config[\"postgis\"][\"host\"]=\"${PG_HOST}\"" data/config/osm-bright/configure.py
	sed -i "/\"port\"/c\config[\"postgis\"][\"port\"]=\"${PG_PORT}\"" data/config/osm-bright/configure.py
	sed -i "/\"dbname\"/c\config[\"postgis\"][\"dbname\"]=\"${PG_DB}\"" data/config/osm-bright/configure.py
	sed -i "/\"user\"/c\config[\"postgis\"][\"user\"]=\"${PG_USER}\"" data/config/osm-bright/configure.py
	sed -i "/\"password\"/c\config[\"postgis\"][\"password\"]=\"${PG_PASSWORD}\"" data/config/osm-bright/configure.py
	docker-compose build
	docker-compose up

cache-tiles:
	docker-compose exec renderd render_list -a -z 0 -Z 7
