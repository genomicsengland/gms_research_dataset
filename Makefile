include .env

psql_cmd = psql -h $(DEST_DB_HOST) -p $(DEST_DB_PORT) -U $(DEST_DB_USER) $(DEST_DB_NAME)
psql_cmd_schema = psql 'host=$(DEST_DB_HOST) user=$(DEST_DB_USER) dbname=$(DEST_DB_NAME) port=$(DEST_DB_PORT) options=--search_path=$(DEST_DB_SCHEMA)'

build_dest_db:
	$(psql_cmd) -c 'create schema $(DEST_DB_SCHEMA);'
	$(psql_cmd_schema) < dest_db_ddl.sql
	$(psql_cmd_schema) -c 'insert into release (version, release_date) values ($(RELEASE_VERSION), $(RELEASE_DATE)::text::date);'

drop_dest_db:
	$(psql_cmd) -c 'drop schema $(DEST_DB_SCHEMA) cascade;'

populate_data:
	python data_transfer.py

build_and_populate: build_dest_db populate_data
