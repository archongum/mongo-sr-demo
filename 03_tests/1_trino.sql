-- # Source
select * from mongo.test.competitor_other_on_sale;

-- # Create schema
-- # Use default location: s3a://<bucket_name>/user/hive/warehouse/<db_name>.db/
create schema minio1.ods_mongo;
create schema minio2.ods_mysql;
show create schema minio1.ods_mongo;
show create schema minio2.ods_mysql;

-- # Create table 1
drop table if exists minio1.ods_mongo.ods_mongo_competitor_other_on_sale;
CREATE TABLE minio1.ods_mongo.ods_mongo_competitor_other_on_sale (
    _id varchar,
    mall varchar,
    onsale_time varchar,
    brand varchar,
    spu_id varchar,
    skc_id varchar,
    skcs_id varchar,
    price varchar,
    prices varchar,
    product_tag varchar,
    multi_color varchar,
    categories varchar,
    skc_name varchar,
    currency varchar,
    sell_list varchar,
    skc_create_time varchar
)
WITH (
    format = 'parquet',
    partitioned_by = ARRAY['skc_create_time'],
    external_location = 's3a://bucket-1/user/hive/warehouse/ods_mongo.db/ods_mongo_competitor_other_on_sale/'
);

-- # Create table 2
DROP TABLE if exists minio2.ods_mysql.ods_mysql_competitor_other_on_sale;
CREATE TABLE minio2.ods_mysql.ods_mysql_competitor_other_on_sale (
    _id varchar, mall varchar, onsale_time varchar, brand varchar, spu_id varchar, skc_id varchar, skcs_id varchar, price varchar, prices varchar, product_tag varchar, multi_color varchar, categories varchar, skc_name varchar, currency varchar, sell_list varchar, skc_create_time varchar
)
WITH (
    format = 'parquet',
    partitioned_by = ARRAY['skc_create_time'],
    external_location = 's3a://bucket-2/user/hive/warehouse/ods_mysql.db/ods_mysql_competitor_other_on_sale/'
);

-- # Transform
-- insert into minio1.ods_mongo.ods_mongo_competitor_other_on_sale
insert into minio2.ods_mysql.ods_mysql_competitor_other_on_sale
select
    _id, mall, onsale_time, brand, spu_id, skc_id, skcs_id, price, prices, product_tag, multi_color, categories, skc_name, currency, sell_list, skc_create_time
from mongo.test.competitor_other_on_sale;

-- # Verify
select * from minio1.ods_mongo.ods_mongo_competitor_other_on_sale;
select * from minio2.ods_mysql.ods_mysql_competitor_other_on_sale;
show create table minio1.ods_mongo.ods_mongo_competitor_other_on_sale;
show create table minio2.ods_mysql.ods_mysql_competitor_other_on_sale;

call minio1.system.sync_partition_metadata('ods_mongo', 'ods_mongo_competitor_other_on_sale', 'FULL');
