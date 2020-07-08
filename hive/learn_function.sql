--hive的函数总结
/*
  UDTF函数-explode
  可以将一个array或者map类型的字段展开，其中 explode(array)使得结果中将 array 列表里的每个元素生成
  一行；explode(map)使得结果中将 map 里的每一对元素作为一行，key 为一列，value 为一列
 */
create table if not exists t_explode
(
    id       int,
    name     string,
    location array<string>,
    city     array<int>
) row format delimited fields terminated by ","
    collection items terminated by "|";
--加载数据
load data local inpath "/opt/hivedata/explode.txt" into table t_explode;
select explode(location)
from t_explode;
select explode(location)
from t_explode
where name = "kobe";
--报错：当使用UDTF函数的时候，hive只允许对已拆分字段进行访问
select name, explode(location)
from t_explode;

/*
lateral view（侧视图）
常见的UDTF函数有 json_tuple，parse_url_tuple，split, explode
意义是为了配合UDTF来使用,把某一行数据拆分成多行数据.不加lateral view的UDTF只能提取单个字段拆分,
并不能塞会原来数据表中.加上lateral view就可以将拆分的单个字段数据与原始表数据关联上.
*/
select subview.*
from t_explode lateral view explode(location) subview;
--from子句后面可以有多个leteral view
select a, b
from t_explode lateral view explode(location) line1 as a
         lateral view explode(city) line2 as b;

--行列转换
--多行转单列
/*
数据格式
+-----------------+-----------------+-----------------+--+
| row2col_1.col1  | row2col_1.col2  | row2col_1.col3  |
+-----------------+-----------------+-----------------+--+
| a               | b               | 1               |
| a               | b               | 2               |
| a               | b               | 3               |
| c               | d               | 4               |
| c               | d               | 5               |
| c               | d               | 6               |
+-----------------+-----------------+-----------------+--+
转换为
+-------+-------+--------+--+
| col1  | col2  |  _c2   |
+-------+-------+--------+--+
| a     | b     | 1-2-3  |
| c     | d     | 4-5-6  |
+-------+-------+--------+--+
--收集函数  把指定的字段收集成为一个集合 set list
collect_set() 去除重复元素 UDAF函数
collect_list() 不去除重复元素 UDAF函数
--类型转换函数
cast(1 as string) UDF函数
--拼接函数
concat_ws(参数1，参数2)用于进行string array<string>的拼接 UDAF函数
参数1：指定分隔符
参数2：拼接的内容
*/
create table if not exists row2col_1
(
    col1 string,
    col2 string,
    clo3 string
) row format delimited fields terminated by ",";
--加载数据
load data local inpath "/opt/hivedata/row2col_1.txt" into table row2col_1;
select collect_set(col3)
from row2col_1;
select collect_list(col3)
from row2col_1
group by col1, col2;
--结果
select col1, col2, concat_ws("-", collect_list(cast(col3 as string))) as c3
from row2col_1
group by col1, col2;

--单列转多行
/*
+-----------------+-----------------+-----------------+--+
| col2row_2.col1  | col2row_2.col2  | col2row_2.col3  |
+-----------------+-----------------+-----------------+--+
| a               | b               | 1,2,3           |
| c               | d               | 4,5,6           |
+-----------------+-----------------+-----------------+--+
转化
+-----------------+-----------------+----------+--+
| col2row_2.col1  | col2row_2.col2  | tmp.col  |
+-----------------+-----------------+----------+--+
| a               | b               | 1        |
| a               | b               | 2        |
| a               | b               | 3        |
| c               | d               | 4        |
| c               | d               | 5        |
| c               | d               | 6        |
+-----------------+-----------------+----------+--+
--split()分割字符串函数 UDF函数
*/
create table col2row_2
(
    col1 string,
    col2 string,
    col3 string
) row format delimited fields terminated by "\t";
load data local inpath "/opt/hivedata/row2col_2.txt" into table col2row_2;
--
select a.col1, a.col2, tmp.*
from col2row_2 a lateral view explode(split(col3, ",")) tmp;