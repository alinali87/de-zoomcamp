import argparse
import os
import pandas as pd
from time import time
from sqlalchemy import create_engine


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url
    if url.endswith('csv.gz'):
        csv_name = 'output.csv.gz'
    else:
        csv_name = 'output.csv'

    os.system(f'wget {url} -O {csv_name}')

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
    engine.connect()
    df_iter = pd.read_csv(csv_name, parse_dates=['lpep_pickup_datetime', 'lpep_dropoff_datetime'], iterator=True, chunksize=100000)

    df = next(df_iter)
    df.head(0).to_sql(name=table_name, con=engine, if_exists='replace')
    df.to_sql(name=table_name, con=engine, if_exists='append')

    while True:
        t_start = time()
        try:
            df = next(df_iter)
            df.to_sql(name=table_name, con=engine, if_exists='append')
        except StopIteration as exc:
            t_end = time()
            print(f'Inserted FINAL chuck into postgres... Took %.3f second.' % (t_end - t_start))
            print(exc)
            break

        t_end = time()
        print(f'Inserted next chuck into postgres... Took %.3f second.' % (t_end - t_start))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Load CSV to Postgres.')
    parser.add_argument('--user', help='user name for postgres db')
    parser.add_argument('--password', help='password for user for Postgres')
    parser.add_argument('--host', help='host for Postgres')
    parser.add_argument('--port', help='port number for Postgres')
    parser.add_argument('--db', help='database name in Postgres')
    parser.add_argument('--table_name', help='table name to load data in Postgres')
    parser.add_argument('--url', help='url to load data from')

    args = parser.parse_args()
    main(args)
