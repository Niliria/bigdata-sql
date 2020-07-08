/*
--查询语法
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
    FROM table_reference
    [WHERE where_condition]
    [GROUP BY col_list [HAVING condition]]
    [CLUSTER BY col_list
      | [DISTRIBUTE BY col_list] [SORT BY| ORDER BY col_list]
    ]
    [LIMIT number]
 */
--常用函数
--求总行数 count
select count(*) cnt
from emp;
--求工资的最大值
select max(sal) max_sal
from emp;
--求工资的最小值
select min(sal) min_sal
from emp;
--求工资的总和
select sum(sal) sum_sal
from emp;
--求工资的平均值
select avg(sal) avg_sal
from emp;
--limit 语句
select *
from emp
limit 5;
--where语句
--where 将不满足条件的行过滤掉
select *
from emp
where sal > 1500;
-- between and 500-1000
select *
from emp
where sal between 500 and 1000;
-- 查询comm为空的所有员工信息 is null
select *
from emp
where comm is null;
-- 查询sal是1500和5000的员工信息 in
select *
from emp
where sal in (1500, 5000);
-- 查询薪水是大于1000部门是30 and
select *
from emp
where sal > 1000
  and deptno = 30;
-- 查询薪水大于1000或者部门是30的
select *
from emp
where sal > 1000
   or deptno = 30;
-- 查询除了20部门和30部门以外的员工信息
select *
from emp
where deptno not in (20, 30);

--分组Group by
-- GROUP BY语句通常会和聚合函数一起使用，按照一个或者多个列队结果进行分组，然后对每个组执行聚合操作。
--计算emp表每个部门的平均工资
select t.deptno, avg(t.sal) avg_sal
from emp t
group by t.deptno;
--计算emp每个部门中每个岗位的最高薪水
select t.deptno, t.job, max(t.sal) max_sal
from emp t
group by t.deptno, t.job;

--Having语句
--求每个部门的平均薪水大于2000的部门
select t.deptno, avg(sal) avg_sal
from emp t
group by t.deptno
having avg_sal > 2000;

--join
--内连接 只有进行连接的两个表中都存在与连接条件相匹配的数据才会被保留下来。
select e.empno, e.ename, d.depton, d.dname
from emp e
         join dept d
              on e.deptno = d.depton;
--左外连接 JOIN操作符左边表中符合WHERE子句的所有记录将会被返回。
select e.empno, e.ename, d.depton, d.dname
from emp e
         left join dept d
                   on e.deptno = d.depton;
--右外连接 JOIN操作符右边表中符合WHERE子句的所有记录将会被返回。
select e.empno, e.ename, d.depton, d.dname
from emp e
         right join dept d
                    on e.deptno = d.depton;
--满外连接 将会返回所有表中符合WHERE语句条件的所有记录。如果任一表的指定字段没有符合条件的值的话，那么就使用NULL值替代。
select e.empno, e.ename, d.depton, d.dname
from emp e
         full join dept d
                   on e.deptno = d.depton;