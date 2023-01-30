# week 1: draft notes

### build image from Dockerfile in current directory
docker build -t dez:pandas .

### check what images i have locally
docker images

### check what networks i have in docker
docker network ls

### check that my dockerized python script works
docker run -it dez:pandas 2023-01-26

### run postgres
```
docker run -it \
-e POSTGRES_USER="root" \
-e POSTGRES_PASSWORD="root" \
-e POSTGRES_DB="ny_taxi" \
-v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
-p 5432:5432
postgres:13
```

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
