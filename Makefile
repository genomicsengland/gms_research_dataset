include .env

build_dest_db:
	psql -h $(DEST_DB_HOST) -p $(DEST_DB_PORT) -U $(DEST_DB_USER) $(DEST_DB_NAME) < dest_db_ddl.sql

drop_dest_db:
	psql -h $(DEST_DB_HOST) -p $(DEST_DB_PORT) -U $(DEST_DB_USER) $(DEST_DB_NAME) < drop_dest_db.sql

populate_data:
	python data_transfer.py

build_and_populate: build_dest_db populate_data
