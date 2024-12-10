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

- mysql1: jdbc:mysql://mysql1:3306/hive
- mysql2: jdbc:mysql://mysql2:3306/hive

### MinIO

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/minio/
docker compose up -d
```

Services

- minio1: minio1:9000 bucket-1
- minio2: minio2:9000 bucket-2
- minio1-ui: http://127.0.0.1:19001/
- minio2-ui: http://127.0.0.1:29002/

### MongoDB

Deploy

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/
docker compose up -d
```

Services

- mongo: mongodb://root:root123@mongo:27017/
- mongo-express: http://127.0.0.1:8081/

#### Import mock data

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/

# Collection: competitor_other_on_sale
export COLLECTION_NAME=competitor_other_on_sale
docker compose cp ./mock_data/$COLLECTION_NAME.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host 'mongo:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection $COLLECTION_NAME --file /tmp/$COLLECTION_NAME.json --jsonArray --mode upsert

# Collection: xxx
```

#### Defind schema for Trino

```sh
cd /workspace/mongo-sr-demo/01_had/mongo/
docker compose cp ./mock_data/_schema.json mongo:/tmp/
docker compose exec -it mongo \
    mongoimport --host 'mongo:27017' -u 'root' -p 'root123' --authenticationDatabase 'admin' \
     --db test --collection _schema --file /tmp/_schema.json --jsonArray --mode upsert
```


#### (Option) Verify

```sh
alias mongosh="docker run -ti --rm --network host alpine/mongosh mongosh"
mongosh "mongodb://root:root123@127.0.0.1:27017/"
```

### StarRocks

> [!NOTE] Start Hive MetaStore FIRST!

Deploy 

```sh
cd /workspace/mongo-sr-demo/01_had/sr/
# Cleanup first
docker compose down && docker network prune -f && docker volume prune -f
docker compose up -d
```

Services

- sr: jdbc:mysql://127.0.0.1:9030/

## 02_needed

### Hive MetaStore

Deploy

```sh
cd /workspace/mongo-sr-demo/02_needed/metastore/
docker compose up -d
```

Services

- metastore1: thrift://metastore1-ha1:9083,thrift://metastore1-ha2:9083
- metastore2: thrift://metastore2-ha1:9083,thrift://metastore2-ha2:9083

### Trino

Deploy

```sh
cd /workspace/mongo-sr-demo/02_needed/trino/
# Cleanup first
docker compose down && docker network prune -f && docker volume prune -f
docker compose up -d
```

Services

- trino: jdbc:trino://127.0.0.1:18010/
- trino-ui: http://127.0.0.1:18010/

## 03_tests

Transform: mongo -> s3 parquet

[1_trino.sql](./03_tests/1_trino.sql)

Load: StarRocks Hive Catalog

[2_sr.sql](./03_tests/2_sr.sql)

## Cleanup

```sh
# Remove containers
docker ps -a | cut -d ' ' -f 1 | sed '1d'  | xargs docker rm -f
# Remove networks
docker network prune -f
# Remove volumes
docker volume prune -f
# Remove local data
sudo rm /workspace/mongo-sr-demo/0[1-2]_*/*/data* -rf
```
