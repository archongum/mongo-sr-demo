# mongo-sr-demo

- Extract: mongo
- Transform: Trino, parquet 
- Load: SR EXTERNAL table stored as PARQUET location s3://

## 01_had

### MySQL

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/mysql/
docker compose up -d
```

Services

- mysql1: 127.0.0.1:13306
- mysql2: 127.0.0.1:23306

### MinIO

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/minio/
docker compose up -d
```

Services

- minio1: 127.0.0.1:19000 bucket-1
- minio2: 127.0.0.1:29000 bucket-2

### MongoDB

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/
docker compose up -d
```

Services

- mongo: 127.0.0.1:27017
- mongo-express: http://127.0.0.1:8081/

#### Import mock data

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/

# Collection: competitor_other_on_sale
export COLLECTION_NAME=competitor_other_on_sale
docker compose cp ./mock_data/$COLLECTION_NAME.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection $COLLECTION_NAME --file /tmp/$COLLECTION_NAME.json --jsonArray --mode upsert

# Collection: xxx
```

#### Defind schema for Trino

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/
docker compose cp ./mock_data/_schema.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host '127.0.0.1:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection _schema --file /tmp/_schema.json --jsonArray --mode upsert
```


#### (Option) Verify

```sh
alias mongosh="docker run -ti --rm --network host alpine/mongosh mongosh"
mongosh "mongodb://root:root123@127.0.0.1:27017/"
```

### StarRocks

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/sr/
# Cleanup first
docker compose down && docker network prune -f && docker volume prune -f
docker compose up -d
```

Services

- sr: 127.0.0.1:9030

## 02_needed

### Hive MetaStore

Deploy

```sh
cd /workspace/mongo-sr-demo/02_needed/metastore/
docker compose up -d
```

Services

- HMS 1: thrift://127.0.0.1:19083,thrift://127.0.0.1:19084
- HMS 2: thrift://127.0.0.1:29083,thrift://127.0.0.1:29084

### Trino

Deploy

```sh
cd /workspace/mongo-sr-demo/02_needed/trino/
# Cleanup first
docker compose down && docker network prune -f && docker volume prune -f
docker compose up -d
```

Services

- trino: 127.0.0.1:18010

## 03_tests

Transform: mongo -> s3 parquet

[1_trino.sql](./03_tests/1_trino.sql)

Load: StarRocks Hive Catalog

[2_sr.sql](./03_tests/2_sr.sql)
