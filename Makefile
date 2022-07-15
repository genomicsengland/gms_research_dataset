include .env

psql_cmd = psql -h $(DEST_DB_HOST) -p $(DEST_DB_PORT) -U $(DEST_DB_USER) $(DEST_DB_NAME)

build_dest_db:
	$(psql_cmd) < dest_db_ddl.sql
	$(psql_cmd) -c 'insert into release (version, release_date) values ($(RELEASE_VERSION), $(RELEASE_DATE)::text::date);'
	$(psql_cmd) -c 'insert into encryption_seed values ($(ENCRYPTION_SEED));'

drop_dest_db:
	$(psql_cmd) < drop_dest_db.sql

populate_data:
	python data_transfer.py

build_and_populate: build_dest_db populate_data

export_dataset:
	bash export_tables.sh

run_unittests:
	python -m unittest -v

run_tests: drop_dest_db run_unittests
