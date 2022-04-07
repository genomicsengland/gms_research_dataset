import os
from string import Template

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

sql_script_location = 'data_extraction_sql_scripts'
load_dotenv()


def get_engine(host, port, db, user, pwd):
    """
    return a db connection engine for the given db
    """
    conn_string = 'postgresql+psycopg2://$user:$pwd@$host:$port/$db'
    db_conn_string = Template(conn_string).safe_substitute(
        {'host': host, 'port': port, 'db': db, 'user': user, 'pwd': pwd}
    )
    return create_engine(db_conn_string)


def get_ngis_db_engine(db):
    return get_engine(
        os.getenv('SRC_DB_HOST'),
        os.getenv('SRC_DB_PORT'),
        'ngis_' + db + '_prod',
        os.getenv('SRC_DB_USER'),
        os.getenv('SRC_DB_PWD'),
    ).connect()


def get_dest_connection():
    return get_engine(
        os.getenv('DEST_DB_HOST'),
        os.getenv('DEST_DB_PORT'),
        os.getenv('DEST_DB_NAME'),
        os.getenv('DEST_DB_USER'),
        os.getenv('DEST_DB_PWD'),
    ).connect()


def list_sql_scripts(loc):
    """
    return a dictionary of folders and sql files at loc
    :params loc: directory to search
    """

    out = {}

    for root, dirs, files in os.walk(loc):

        [out.update({x: []}) for x in dirs]

        for f in sorted(files):

            if f.endswith('.sql'):

                d = os.path.basename(root)

                out[d].append(f)

    return out


def load_df_to_db(tab, conn, df):
    """
    load pandas dataframe into a database connection
    :param tab: name of destination table
    :param conn: target database connection
    :param df: pandas dataframe to be loaded
    """

    df.to_sql(
        tab,
        conn,
        index=False,
        if_exists='append',
    )


def read_sql_to_df(sql, conn):
    """
    read sql into pandas df
    :param sql: sql query
    :param conn: target database connection
    :returns: pandas df
    """

    return pd.read_sql(sql, conn)


if __name__ == '__main__':

    scripts = list_sql_scripts(sql_script_location)

    dest_conn = get_dest_connection()

    for db in scripts.keys():

        conn = get_ngis_db_engine(db)

        for tab in scripts[db]:

            with open(os.path.join(sql_script_location, db, tab)) as f:

                s = f.read()

                d = read_sql_to_df(s, conn)

                load_df_to_db(os.path.splitext(tab)[0].split('__')[1], dest_conn, d)
