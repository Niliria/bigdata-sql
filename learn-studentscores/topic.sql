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
--第四题：查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩(包括有成绩的和无成绩的)
--第五题：查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩
--第六题：查询"李"姓老师的数量
--第七题：查询学过"张三"老师授课的同学的信息
--第八题：查询没学过"张三"老师授课的同学的信息
--第九题：查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息
--第十题：查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息
--第十一题：查询没有学全所有课程的同学的信息
--第十二题：查询至少有一门课与学号为"01"的同学所学相同的同学的信息
