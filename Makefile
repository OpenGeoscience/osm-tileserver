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
