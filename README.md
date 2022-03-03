# README

This code extracts a dataset of clinical data from GMS databases that can be made available to researchers.

The overall workflow is to query GMS databases and write the results to an intermediate database which has views representing the final, filtered dataset, then export those views to flatfiles for upload to the research environments.

The code has been developed with Python 3.9.4 using a local Postgres v14.2.

It requires a `.env` file with the following variables:

```
RELEASE_DATE # date of the expected release
RELEASE_VERSION # version number of the expected release
DEST_DB_HOST # connection details for the intermediate database
DEST_DB_PORT
DEST_DB_NAME
DEST_DB_USER
DEST_DB_PWD
SRC_DB_HOST # connection details for the GMS database
SRC_DB_PORT
SRC_DB_USER
SRC_DB_PWD
PGPASSFILE='.pgpass_dest' # location of the pgpass file, required by psql
EXPORT_LOCATION # filepath for the export location
```
