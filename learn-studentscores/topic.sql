use db_learn;
--第一题：查询"01"课程比"02"课程成绩高的学生的信息及课程分数
--解法1 18s
select c.*, a.s_score, b.s_score
from (select s_id, c_id, s_score from score where c_id = "01") as a
         inner join
         (select s_id, c_id, s_score from score where c_id = "02") as b on a.s_id = b.s_id
         inner join student c on c.s_id = a.s_id and c.s_id = b.s_id
where a.s_score > b.s_score;
--解法2 15s
select a.*, b.s_score, c.s_score
from student a
         join score b on b.c_id = "01"
         join score c on c.c_id = "02"
where a.s_id = b.s_id
  and a.s_id = c.s_id
  and b.s_score > c.s_score;

--解法3 17s
select a.*, b.s_score, c.s_score
from student a
         join score b on a.s_id = b.s_id and b.c_id = "01"
         left join score c on a.s_id = c.s_id and c.c_id = "02"
where b.s_score > c.s_score;

--第二题：查询"01"课程比"02"课程成绩低的学生的信息及课程分数
--解法1 15s
select c.*, a.s_score, b.s_score
from (select * from score where c_id = "01") as a
         inner join (select * from score where c_id = "02") as b
                    on a.s_id = b.s_id
         inner join student c on c.s_id = a.s_id
where a.s_score < b.s_score;
--解法2 14s
select a.*, b.s_score, c.s_score
from student a
         join score b on b.c_id = "01"
         join score c on c.c_id = "02"
where a.s_id = b.s_id
  and a.s_id = c.s_id
  and b.s_score < c.s_score;
--解法3
select a.*, b.s_score, c.s_score
from student a
         join score b on a.s_id = b.s_id and b.c_id = "01"
         left join score c on a.s_id = c.s_id and c.c_id = "02"
where b.s_score < c.s_score;

--第三题：查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩
--解法1
select a.s_id, a.s_name, round(avg(b.s_score), 1) as avg_score
from student a
         join score b on a.s_id = b.s_id
group by a.s_id, a.s_name
having avg(b.s_score) >= 60;
--解法2
select a.s_id, a.s_name, tmp.avg_score
from student a
         join (select b.s_id, round(avg(b.s_score), 1) as avg_score from score b group by s_id) as tmp
              on a.s_id = tmp.s_id
where tmp.avg_score >= 60;

--第四题：查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩(包括有成绩的和无成绩的)
--解法1
select a.s_id, a.s_name, tmp.avg_score
from student a
         join (select b.s_id, round(avg(b.s_score), 1) as avg_score from score b group by b.s_id) as tmp
              on tmp.avg_score < 60
where a.s_id = tmp.s_id
union all
select a2.s_id, a2.s_name, 0 as avg_score
from student a2
where a2.s_id not in (select distinct b2.s_id from score b2);
--解法2
select a.s_id, a.s_name, round(avg(s.s_score), 1) as avg_score
from student a
         inner join score s on a.s_id = s.s_id
group by a.s_id, a.s_name
having avg(s.s_score) < 60
union all
select a2.s_id, a2.s_name, 0 as avg_score
from student a2
where a2.s_id not in (select distinct s2.s_id from score s2);


--第五题：查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩
select a.s_id, a.s_name, count(s.c_id) as total_couses, sum(s.s_score) as sum_scores
from student a
         left join score s on s.s_id = a.s_id
group by a.s_id, a.s_name;

--第六题：查询"李"姓老师的数量
select count(*)
from teacher t
where t.t_name like "李%"
group by t.t_name;

--第七题：查询学过"张三"老师授课的同学的信息
select a.*
from student a
         join score s on a.s_id = s.s_id
         join course c on c.c_id = s.c_id
         join teacher t on t.t_id = c.t_id and t.t_name = "张三";

--第八题：查询没学过"张三"老师授课的同学的信息
select a.*
from student a
         left join (select s.s_id
                    from score s
                             join course c on s.c_id = c.c_id
                             join teacher t on t.t_id = c.t_id and t_name = "张三") tmp
                   on tmp.s_id = a.s_id
where tmp.s_id is null;

--第九题：查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息
--解法1
select a.*
from student a
         join (select s.s_id from score s where s.c_id = "01") tmp1
              on a.s_id = tmp1.s_id
         join (select s2.s_id from score s2 where c_id = "02") tmp2
              on a.s_id = tmp2.s_id;
--解法2
select a.*
from student a
         join score s1 on s1.c_id = "01"
         join score s2 on s2.c_id = "02"
where a.s_id = s1.s_id
  and a.s_id = s2.s_id;
--解法3
select a.*
from student a
         join score s1 on a.s_id = s1.s_id and s1.c_id = "01"
         inner join score s2 on a.s_id = s2.s_id and s2.c_id = "02";

--第十题：查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
--第十一题：查询没有学全所有课程的同学的信息
--第十二题：查询至少有一门课与学号为"01"的同学所学相同的同学的信息
