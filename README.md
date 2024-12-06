# mongo-sr-demo

- Extract: mongo
- Transform: Trino, parquet 
- Load: SR EXTERNAL table stored as PARQUET location s3://

## Extract: mongo

### Startup

```sh
cd /workspace/mongo-sr-demo/mongo/
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
cd /workspace/mongo-sr-demo/mongo/
export COLLECTION_NAME=competitor_other_on_sale
docker compose cp ./mock_data/$COLLECTION_NAME.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection $COLLECTION_NAME --file /tmp/$COLLECTION_NAME.json --jsonArray --mode upsert

# Collection: xxx
```

### Defind schema for Trino

```sh
cd /workspace/mongo-sr-demo/mongo/
docker compose cp ./mock_data/_schema.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection _schema --file /tmp/_schema.json --jsonArray --mode upsert
```


## Load: minio

### minio1

```sh
cd /workspace/mongo-sr-demo/minio1/
docker compose up -d
```

### minio2

```sh
cd /workspace/mongo-sr-demo/minio2/
docker compose up -d
```

## Metastore: Hive Metastore

### TMP: build image

```sh
# build image locally, will removing to dockerhub
docker build . --tag archongum/hive:4.0.1
```

### metastore1

```sh
cd /workspace/mongo-sr-demo/metastore1/
docker compose up -d
```

### metastore2

```sh
cd /workspace/mongo-sr-demo/metastore2/
docker compose up -d
```

## Transform: Trino

Installation

```sh
cd /workspace/mongo-sr-demo/
docker run -d --rm --name trino -v $(pwd)/trino:/etc/trino --network host trinodb/trino:466
```

Transform: mongo -> s3 parquet

[trino.sql](./1_trino.sql)

## SR

```sh
cd /workspace/mongo-sr-demo/
docker run -d --rm --name sr --network host starrocks/allin1-ubuntu:3.1.2
```

[trino.sql](./2_sr.sql)
