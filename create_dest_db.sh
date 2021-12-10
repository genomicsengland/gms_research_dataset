#!/bin/bash
source .env
export PGPASSFILE='.pgpass_dest'
psql -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER $DEST_DB_NAME < dest_db_ddl.sql
