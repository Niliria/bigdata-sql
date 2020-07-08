--DDL数据定义
-- 创建数据库
create database if not exists db_hive;
-- 创建库并指定位置信息
create database if not exists test location "/yummy/db_test";
-- 查看库的描述信息
describe database extended test;
-- 显示所有的数据库
show databases;
-- 过滤显示数据库
show databases like "t*";
--切换数据库
use test;
-- 删除库(没有表)
drop database if exists db_hive;
-- 删除库(包含表 关键字cascade 这样可以使hive先删除库中的表然后再删除库)
drop database if exists db_test cascade;
--修改数据库 数据库的其他元数据信息都是不可更改的，包括数据库名和数据库所在的目录位置。
alter database test set dbproperties ("createTime" = "20200622");
/*
--建表语法:顺序不能错  表类型-字段-表描述信息-分区-分桶-指定文件数据分隔符-指定文件的存储格式-指定表的位置
CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name      -
[(col_name data_type [COMMENT col_comment], ...)]
[COMMENT table_comment]
[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
[CLUSTERED BY (col_name, col_name, ...)
[SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS]
[ROW FORMAT row_format]
[STORED AS file_format]
[LOCATION hdfs_path]
*/
-- 创建表(字段类型为array,map,struct类型)
create table if not exists t_2
(
    name     string,
    friends  array<string>,
    children map<string,int>,
    address  struct<street:string,city:string>
)
-- 使用默认的SerDe类指定字段之间的分割符
    row format delimited fields terminated by ","
--         指定集合之间的分割符
        collection items terminated by "_"
--         指定map类型kv之间的分割符
        map keys terminated by ":"
--         指定换行符
        lines terminated by "\n";

-- 创建一个普通表
create table if not exists student
(
    id   int,
    name string,
    age  int
)
-- 指定分隔符 使用默认的SerDe类指定分割符 字段之间的分隔符为‘\t’
    row format delimited fields terminated by "\t"
    --  指定存储文件的数据类型 默认textFile  orc,parquet,sequenceFile
    --  TextFile与SequenceFile是行存储
    --  ORC与Parquet是列式存储
    stored as textfile
--  指定表在HDFS集群上的位置
    location "/user/hive/warehouse/student";

-- 根据查询结果创建表
create table if not exists student2 as
select id, name, age
from student;
-- 根据已经存在的表结构创建表
create table if not exists student3 like student;

-- 查看这个表的详细信息
describe extended t_2;
-- 使用formatted可以提供更加可读的输出信息
describe formatted student;
-- 查看建表语句
show create table student2;
--内部表转成外部表
alter table t_user
    set tblproperties ("EXTERNAL" = "FALSE");
--外部表转换成内部表
alter table t_user
    set tblproperties ("EXTERNAL" = "FALSE");
-- 删除表
drop table t_2;
--查看是内部表还是外部表 属性table Type:MANAGD_TABLE管理表,EXTERNAL_TABLE外部表
desc formatted test.student;
-- 查看表的分区
show partitions t_user_mp;
-- 重命名表
alter table t_user
    rename to t_user_p;
/*
 添加和替换列语法
 ALTER TABLE table_name ADD|REPLACE COLUMNS (col_name data_type [COMMENT col_comment], ...)
 */
-- 添加列
alter table test.student
    add columns (sex string);
-- 替换列
alter table test.student
    replace columns (sno int,sname string,loc string);

/*
 --更新列 语法
 ALTER TABLE table_name CHANGE [COLUMN] col_old_name col_new_name column_type [COMMENT col_comment] [FIRST|AFTER column_name]
 */
alter table test.student
    change column sex desc int;

--删除表的分区
alter table t_user_p
    drop partition (guojia = "shanghai");
--添加分区
alter table t_user_p
    add if not exists partition (guojia = "tuerqi");
--修改分区
alter table t_user_p
    partition (guojia = "shanghai") rename to partition (guojia = "nanjing");

-- 创建部门表 外部表；删除该表并不会删除掉这份数据，不过描述表的元数据信息会被删除掉。
create external table if not exists dept
(
    depton int,
    dname  string,
    loc    int
)
    row format delimited fields terminated by "\t";
-- 创建员工表 外部表；
create external table if not exists emp
(
    empno    int,
    ename    string,
    job      string,
    mgr      int,
    hiredate string,
    sal      double,
    comm     double,
    deptno   int
)
    row format delimited fields terminated by "\t";
-- 创建学生表 管理表/内部表 当我们删除一个管理表时，Hive也会删除这个表中数据
create table if not exists student
(
    Sno   int,
    Sname string,
    Sex   string,
    Sage  int,
    Sdept string
) row format delimited fields terminated by ",";

-- 创建一个分区表 分区字段不能是表中已有字段
create table t_user
(
    id      int,
    name    string,
    country string
) partitioned by (guojia string) row format delimited fields terminated by ",";


-- 创建二级分区表
create table if not exists t_user_mp
(
    id      int,
    name    string,
    country string
) partitioned by (guojia string,province string)
    row format delimited fields terminated by ",";