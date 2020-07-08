-- 原始日志数据表
create table ods_weblog_origin
(
    valid           string,
    remote_addr     string,
    remote_user     string,
    time_local      string,
    request         string,
    status          string,
    body_bytes_sent string,
    http_referer    string,
    http_user_agent string
)
    partitioned by (datestr string)
    row format delimited
        fields terminated by '\001';

-- 点击流模型pageviews
create table ods_click_pageviews
(
    session         string,
    remote_addr     string,
    remote_user     string,
    time_local      string,
    request         string,
    visit_step      string,
    page_staylong   string,
    http_referer    string,
    http_user_agent string,
    body_bytes_sent string,
    status          string
)
    partitioned by (datestr string)
    row format delimited
        fields terminated by '\001'

-- 点击流visit模型表
create table ods_click_stream_visit
(
    session     string,
    remote_addr string,
    inTime      string,
    outTime     string,
    inPage      string,
    outPage     string,
    referal     string,
    pageVisits  int
)
    partitioned by (datestr string)
    row format delimited
        fields terminated by '\001';

--创建业务宽表
create table dw_weblog_detail
(
    valid           string, --有效标识
    remote_addr     string, --来源IP
    remote_user     string, --用户标识
    time_local      string, --访问完整时间
    daystr          string, --访问日期
    timestr         string, --访问时间
    month           string, --访问月
    day             string, --访问日
    hour            string, --访问时
    request         string, --请求的url
    status          string, --响应码
    body_bytes_sent string, --传输字节数
    http_referer    string, --来源url
    ref_host        string, --来源的host
    ref_path        string, --来源的路径
    ref_query       string, --来源参数query
    ref_query_id    string, --来源参数query的值
    http_user_agent string  --客户终端标识
)
    partitioned by (datestr string);

--业务宽表插入数据
insert into table dw_weblog_detail partition (datestr = '20181101')
select c.valid,
       c.remote_addr,
       c.remote_user,
       c.time_local,
       substring(c.time_local, 0, 10) as daystr,
       substring(c.time_local, 12)    as tmstr,
       substring(c.time_local, 6, 2)  as month,
       substring(c.time_local, 9, 2)  as day,
       substring(c.time_local, 12, 2) as hour,
       c.request,
       c.status,
       c.body_bytes_sent,
       c.http_referer,
       c.ref_host,
       c.ref_path,
       c.ref_query,
       c.ref_query_id,
       c.http_user_agent
from (SELECT a.valid,
             a.remote_addr,
             a.remote_user,
             a.time_local,
             a.request,
             a.status,
             a.body_bytes_sent,
             a.http_referer,
             a.http_user_agent,
             b.ref_host,
             b.ref_path,
             b.ref_query,
             b.ref_query_id
      FROM ods_weblog_origin a LATERAL VIEW parse_url_tuple(regexp_replace(http_referer, "\"", ""), 'HOST', 'PATH',
                                                            'QUERY',
                                                            'QUERY:id') b as ref_host, ref_path, ref_query, ref_query_id) c;