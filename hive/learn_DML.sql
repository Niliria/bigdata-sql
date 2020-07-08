--DML数据操作
/*
导入数据：
load data [local] inpath '/opt/module/datas/student.txt'
   [overwrite] into table student [partition (partcol1=val1,…)];
--load data:表示加载数据
--local:表示从本地服务器中加载数据即开启metastore服务的本地,不加local表示从HDFS文件系统加载数据
--inpath:表示加载数据的路径
--overwiter:表示覆盖表中已有数据，否则表示追加
--into table:表示加载到那张表
--student:表示具体的表
--partition:表示上传到指定的分区
*/
-- 向学生表中导入数据
load data local inpath "/opt/hivedata/student.txt" into table student;

-- 向外部表导入数据 部门表
load data local inpath "/opt/hivedata/dept.txt" into table dept;
load data local inpath "/opt/hivedata/emp.txt" into table emp;

-- 向分区表中导入数据
load data local inpath "/opt/hivedata/china.txt" into table t_user partition (guojia = "china");
load data local inpath "/opt/hivedata/usa.txt" into table t_user partition (guojia = "USA");

-- 多分区导入数据
load data local inpath "/opt/hivedata/shanghai.txt"
    into table t_user_mp partition (guojia = "china",province = "shanghai");
load data local inpath "/opt/hivedata/beijing.txt"
    into table t_user_mp partition (guojia = 'china',province = 'beijing');
load data local inpath "/opt/hivedata/meiguo.txt"
    into table t_user_mp partition (guojia = "usa",province = "newyork");

-- 清除表中的数据 truncate table只能清除管理表中的数据不能清除外部表中的数据
truncate table student;

-- 通过查询语句向表中添加数据 insert
--基本的数据插入
insert into table test.student partition (guojia = "tuerqi")
values (1, 2, 1);
-- 根据单张表查询结果
insert overwrite table student partition (guojia = "china")
select id, sname, sex
from t_user
where guojia = "china";
--根据多张表查询结果导入数据
--多表插入的关键点在于将所要执行查询的表语句 "from 表名"，放在最开头位置。
--并且要开启动态分区 set hive.exec.dynamic.partition.mode = true;
from db_test.t1
insert
overwrite
table
db_test.t2
partition
(
age
)
select name, address, school, age
insert
overwrite
table
db_test.t3
select name, address
where age > 24;
--将查询结果导出到本地数据未格式化
insert overwrite local directory "/opt/hivedata"
select *
from db_test.t1;
--将查询的结果格式化的导出到本地
insert overwrite local directory "/opt/hivedata"
    row format delimited fields terminated by "\t"
select *
from db_test.t1;
--将查询结果导出到hdfs
insert overwrite directory "/yummy"
    row format delimited fields terminated by "\t"
select *
from db_test.t1;


--查询语句中创建表并且加载数据as select
create table if not exists db_test.t4 as
select name, age, address, school
from db_test.t1;


--  分桶表
-- 开始分桶
set hive.enforce.bucketing =true;
set hive.enforce.bucketing;
-- 创建分桶表
create table stu_buck
(
    Sno   int,
    Sname string,
    Sex   string,
    Sage  int,
    Sdept string
) clustered by (Sno) into 4 buckets
    row format delimited fields terminated by ",";
--加载数据 load data方式是不可以的 hadoop fs -put 也是不可以的 必须是insert + select方式
insert overwrite table stu_buck
select *
from student;

--加载分桶表的第二种方式
set mapreduce.job.reduces=4;
insert overwrite table stu_buck
select *
from student cluster by (sno);

/**
  --分桶表抽样查询
  tablesample是抽样语句，语法：TABLESAMPLE(BUCKET x OUT OF y) 。
  y必须是table总bucket数的倍数或者因子。hive根据y的大小，决定抽样的比例。
   例如，table总共分了4份，当y=2时，抽取(4/2=)2个bucket的数据，当y=8时，抽取(4/8=)1/2个bucket的数据。
  x表示从哪个bucket开始抽取。
   例如，table总bucket数为4，tablesample(bucket 4 out of 4)，表示总共抽取（4/4=）1个bucket的数据，
  抽取第4个bucket的数据。
注意：x的值必须小于等于y的值，否则
FAILED: SemanticException [Error 10061]:
  Numerator should not be bigger than denominator in sample clause for table stu_buck
 */
select *
from stu_buck tablesample (bucket 1 out of 4 on sno);

--数据块抽样查询
/**
  这种抽样方式不一定适用于所有的文件格式。
  另外，这种抽样的最小抽样单元是一个HDFS数据块。
  因此，如果表的数据大小小于普通的块大小128M的话，那么将会返回所有行。
  tablesample (50 percent);按照百分比
  tablesample (30M); 按照文件大小
  tablesample (n rows);这里指定的行数，是在每个InputSplit中取样的行数，也就是，每个Map中都取样n ROWS。

 */
select *
from stu_buck tablesample (0.1 percent);

