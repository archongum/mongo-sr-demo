-- # Catalog 1
DROP CATALOG minio1;
CREATE EXTERNAL CATALOG minio1
PROPERTIES (
    "type" = "hive",
    "hive.metastore.type" = "hive",
    "hive.metastore.uris" = "thrift://metastore1-ha1:9083,thrift://metastore1-ha2:9083",
    -- # 3.1版本的默认值为7200秒太长了，生产环境可以设置成60秒
    "metastore_cache_refresh_interval_sec" = "10",
    "aws.s3.endpoint" = "http://minio1:9000",
    "aws.s3.enable_ssl" = "false",
    "aws.s3.access_key" = "minioadmin",
    "aws.s3.secret_key" = "minioadmin",
    "aws.s3.enable_path_style_access" = "true"
);
show create catalog minio1;

-- # Catalog 2
DROP CATALOG minio2;
CREATE EXTERNAL CATALOG minio2
PROPERTIES (
    "type" = "hive",
    "hive.metastore.type" = "hive",
    "hive.metastore.uris" = "thrift://metastore2-ha1:9083,thrift://metastore2-ha2:9083",
    -- # 3.1版本的默认值为7200秒太长了，生产环境可以设置成60秒
    "metastore_cache_refresh_interval_sec" = "10",
    "aws.s3.endpoint" = "http://minio2:9000",
    "aws.s3.enable_ssl" = "false",
    "aws.s3.access_key" = "minioadmin",
    "aws.s3.secret_key" = "minioadmin",
    "aws.s3.enable_path_style_access" = "true"
);
show create catalog minio2;

show catalogs;
SHOW DATABASES from minio1;
SHOW DATABASES from minio2;
show tables from minio1.ods_mongo;
show tables from minio2.ods_mysql;

-- # 测试查询
-- ## 一般查询
select * from minio1.ods_mongo.ods_mongo_competitor_other_on_sale;
select * from minio2.ods_mysql.ods_mysql_competitor_other_on_sale;
show create table minio1.ods_mongo.ods_mongo_competitor_other_on_sale;
show create table minio2.ods_mysql.ods_mysql_competitor_other_on_sale;
-- ## 复杂查询
with t_base as (
    select
        -- # 数组
        cast(skcs_id as array<string>) as skcs_id,
        -- # 数组.对象
        cast(cast(sell_list as json) as array<json>) sell_list,
        _id, mall, onsale_time, brand, spu_id, skc_id, price, prices, product_tag, multi_color, categories, skc_name, currency, skc_create_time
    from minio2.ods_mysql.ods_mysql_competitor_other_on_sale
)
-- select * from t_base where _id = '6492b5f4c67d58bc614919c4';
select
    t_base._id,
    -- # 数组
    t_base.skcs_id,
    -- # 数组[元素]
    t_base.skcs_id[1] as skcs_id_skc_id,
    -- # 数组
    t_base.sell_list,
    -- # 数组.对象
    t_sell_list.sell,
    -- # 数组.对象.属性
    cast(t_sell_list.sell->'pattern' as varchar) as sell_pattern,
    -- # 数组.对象.对象
    cast(t_sell_list.sell->'color_dict' as json) as sell_color_dict,
    -- # 数组.对象.对象.属性
    cast(cast(t_sell_list.sell->'color_dict' as json)->'BlackColors' as double) as sell_color_dict_BlackColors,
    -- # 其他
    mall, onsale_time, brand, spu_id, skc_id, price, prices, product_tag, multi_color, categories, skc_name, currency, skc_create_time
from t_base
cross join unnest(sell_list) t_sell_list(sell)
where 1=1
    and t_base._id = '6492b5f4c67d58bc614919c4'
;
