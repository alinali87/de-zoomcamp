# week 1

### build image from Dockerfile in current directory
docker build -t my_python:3.9 .

### check what images i have locally
docker images

### check what networks i have in docker
docker network ls

### check that my dockerized python script works
docker run -it my_python:3.9 2023-01-26

### run postgres
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --name pgdb \
  --network pg-network \
  postgres:13

### run pgAdmin
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --name pgadmin \
  --network pg-network \
  dpage/pgadmin4

### convert jupyter notebook to python script
jupyter nbconvert --to=script test_postgres.ipynb

#### if you get a ValueError: No template sub-directory with name 'script' found in the following paths
ln -s /opt/homebrew/share/jupyter/nbconvert ~/Library/Jupyter

### run python script to load taxi data from internet to local postgres
python3 ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_trip_data \
    --url=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz

python3 ingest_green.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_trip_data \
    --url=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz



### run python script to load zones data from internet to local postgres
python3 ingest_zones.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=zones \
    --url=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv

### run python script to load data from local http.server to local postgres
python3 ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_trip_data \
    --url=http://localhost:8000/yellow_tripdata_2021-01.csv.gz


### run dockerized script to load data from internet to local postgres
docker run -it \
    --network=pg-network \
    my_ingest_data:0.0.1 \
    --user=root \
    --password=root \
    --host=pgdb \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_trip_data \
    --url=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz


### docker compose
docker-compose up
docker-compose down

### problems
PROBLEM: Q3. How many taxi trips were totally made on January 15? --> I got 40-50 K trips, which doesn't match any options 17-21 K trips  
TODO: Occasionally I've found that link (it was on top of the google form anyway it's hard to notice) --> https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2023/week_1_docker_sql/homework.md  
This link says that we use green taxi trips (not yellow) for 2019 year (not 2021) as I thought before.

HOWTO: ingest data into postgres  
TODO: 
- probably the pinned message in slack #course-data-engineering (in particular the message written by Ilya Bondarev) will help
- what i did:
  - build image with python script
  `docker build -t my_ingest:0.0.1 .`

  - run `docker-compose up` in postgres folder, file is copied from the message by Ilya Bondarev and slightly modified
  - run my_ingest:0.0.1
  `URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz"`

  ```
  docker run -it \
    --network=postgres_default \
    my_ingest:0.0.1 \
      --user=test \
      --password=test \
      --host=postgres-db-1 \
      --port=6432 \
      --db=ny_taxi \
      --table_name=trips \
      --url=${URL}
  ```

PROBLEM: `bash: psql: command not found`  
TODO:
- install psql (macos): `brew install libpq`
- try (this did not work for me): `If you need to have libpq first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> /Users/laede/.bash_profile`
- instead i did manual assignment (work only for current session): `export PATH=/opt/homebrew/opt/libpq/bin:$PATH`
- check that you have libpq in your PATH: `echo $PATH`
  - you should get smth like this: `/opt/homebrew/opt/libpq/bin:...`
- try psql now: `psql --host=localhost --port 6432 --username=test --dbname=ny_taxi`
  - you should get smth like this:
    Password for user test:
    psql (15.1, server 13.9 (Debian 13.9-1.pgdg110+1))
    Type "help" for help. 
    
    ny_taxi=# /dt 
    ny_taxi-#
