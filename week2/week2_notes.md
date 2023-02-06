
### run python script to ingest datta
```python
python ingest_data.py --user=root --password=root --host=localhost --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz 
```

--> PROBLEM pgAdmin: internal server error

--> let's try without docker-compose
docker network create my-network




docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /workspaces/animated-space-potato/week_1_basics_n_setup/2_docker_sql/data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=my-network \
  --name pg-database \
  postgres:13


docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=my-network \
  --name pgadmin-2 \
  dpage/pgadmin4