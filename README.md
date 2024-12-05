# mongo-sr-demo

- Extract: mongo
- Transform: Trino, parquet 
- Load: SR EXTERNAL table stored as PARQUET location s3://

## Extract: mongo

### Startup

```sh
cd ./mongo/
docker compose up -d
```

### (Option) Verify

```sh
alias mongosh="docker run -ti --rm --network host alpine/mongosh mongosh"
mongosh "mongodb://root:root123@127.0.0.1:27017/"
```

### Import mock data

```sh
# Collection: competitor_other_on_sale
cd ./mongo/
export COLLECTION_NAME=competitor_other_on_sale
docker compose cp ./mock_data/$COLLECTION_NAME.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection $COLLECTION_NAME --file /tmp/$COLLECTION_NAME.json --jsonArray --mode upsert

# Collection: xxx
```

### Defind schema for Trino

```sh
cd ./mongo/
docker compose cp ./mock_data/_schema.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection _schema --file /tmp/_schema.json --jsonArray --mode upsert
```


## Load: minio

### Startup

```sh
cd ./minio/
docker compose up -d
```

## Transform: Trino

Installation

```sh
docker run -d --rm --name trino -v $(pwd)/trino:/etc/trino --network host trinodb/trino:466
```

Transform: mongo -> hive local parquet

```sql
```

## SR

Installation

```sh
# -p 9030:9030 -p 8030:8030 -p 8040:8040 \
docker run -d \
--rm \
--name sr \
--network host \
starrocks/allin1-ubuntu:3.1.2
```

Data Read

```sql
```
