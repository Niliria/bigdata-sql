--多维度分析
--需求：计算该处理批次一天中的个小时的pv
--时间维度
create table dw_pvs_everyhour_oneday
(
    month string,
    day   string,
    hour  string,
    pvs   bigint
) partitioned by (datestr string);

insert into table dw_pvs_everyhour_oneday
select t.month, t.day, t.hour, count(*) as pv
from itheima.dw_weblog_detail t
where datestr = "20181101"
group by t.month, t.day, t.hour;

--需求：计算每天的pvs 维度day
--方式一 dw_pvs_everyhour_oneday记录了每小时的pv 聚合求职
select sum(pvs)
from dw_pvs_everyhour_oneday t
where t.datestr = "20181101";
--方式二 根据day统计
select t.`month`, t.`day`, count(*) as pvs
from dw_weblog_detail t
where datestr = "20181101"
group by t.`month`, t.`day`;