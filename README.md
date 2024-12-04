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
     --db test --collection $COLLECTION_NAME --file /tmp/$COLLECTION_NAME.json --jsonArray

# Collection: xxx
```


## Load: minio

### Startup

```sh
cd ./minio/
docker compose up -d
```

## Load: s3fs

```bash
# Installation
sudo apt update && sudo apt install -y s3fs

# Create mount directory
mkdir -p /workspaces/codespaces-blank/s3fs/minio/warehouse/

# Create secret
cat > /workspaces/codespaces-blank/s3fs/.s3fs-minio.passwd <<EOF
minioadmin:minioadmin
EOF
chmod 600 /workspaces/codespaces-blank/s3fs/.s3fs-minio.passwd

# Mount
s3fs warehouse /workspaces/codespaces-blank/s3fs/minio/warehouse \
-o passwd_file=/workspaces/codespaces-blank/s3fs/.s3fs-minio.passwd \
-o url=http://127.0.0.1:9000 \
-o allow_other \
-o mp_umask=0000 \
-o use_path_request_style \
-f
```

## Transform: Trino

```sh
docker run -d --name trino --restart always -v $(pwd)/trino:/etc/trino --network host trinodb/trino:466
```

## SR
