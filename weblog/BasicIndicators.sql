--pv:一天之内页面被加载的总次数
select count(*) as pv
from dw_weblog_detail t
where t.datestr = "20181101"
  and t.valid = "true";
--uv:一天之内去重的独立访客的数
select count(distinct remote_addr) as uv
from dw_weblog_detail
where datestr = "20181101";
--vv:一天之内的会话（session）总次数
select count(session) as vv
from ods_click_stream_visit t
where datestr = "20181101";
--ip:一天之内不重复的ip
--创建一张临时表用于保存基础指标的信息  便于后续其他查询
create table dw_webflow_basic_info
(
    month string,
    day   string,
    pv    bigint,
    uv    bigint,
    ip    bigint,
    vv    bigint
) partitioned by (datestr string);

select a.*, b.*
from (select count(*) as pv, count(distinct remote_addr) as uv, count(distinct remote_addr) as ip
      from dw_weblog_detail t
      where t.datestr = "20181101") a
         join
     (select count(session) as vv from ods_click_stream_visit t where t.datestr = "20181101") b;
--存入数据
insert into table dw_webflow_basic_info partition (datestr = "20181101")
select '201811', '01', a.*, b.*
from (select count(*) as pv, count(distinct remote_addr) as uv, count(distinct remote_addr) as ips
      from dw_weblog_detail
      where datestr = '20181101') a
         join
     (select count(distinct session) as vvs from ods_click_stream_visit where datestr = "20181101") b;

--复合指标计算
--平均访问频度 人均会话次数==总的会话次数/去重的人=vv/uv  1.075
select count(t.`session`) / count(distinct t.remote_addr)
from ods_click_stream_visit t
where t.datestr = "20181101";
--平均访问深度 人均页面浏览数=总的页面浏览数/去重的人=pv/uv 13.4
select pv / uv
from dw_webflow_basic_info
where datestr = "20181101";
--平均会话时长 总的会话时长/会话的次数
select sum(page_staylong) / count(distinct session)
from ods_click_pageviews
where datestr = "20181101";
--页面跳出率
--inpage="/hadoop-mahout-roadmap/"
select (b.nums / a.vv) * 100
from dw_webflow_basic_info a
         join (select count(*) as nums
               from ods_click_stream_visit
               where datestr = "20181101"
                 and pagevisits = 1
                 and outpage = "/hadoop-mahout-roadmap/") b;
--需求：统计今天每个小时产生的pv数。
select t.month, t.day, t.hour, count(*) as pvs
from dw_weblog_detail t
where t.datestr = "20181101"
group by t.month, t.day, t.hour;





