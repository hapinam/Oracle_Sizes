###Index:
----------

SELECT idx.index_name, SUM(bytes)/1024/1024/1024  AS "SIZE GB"
  FROM dba_segments seg,
       dba_indexes  idx
 WHERE idx.table_owner = Owner  -- put the actual owner
   AND idx.table_name  = Table -- put the actual table
   AND idx.owner       = seg.owner
   AND idx.index_name  = seg.segment_name
 GROUP BY idx.index_name

----------------------------------------------------

###Table:
----------

select OWNER,SEGMENT_NAME,sum(BYTES/1024/1024/1024) "siz in GB"
from dba_extents
where SEGMENT_TYPE = 'TABLE'
group by OWNER,SEGMENT_NAME
order by 3 desc

-----------------------------------------------------

###Tablespace:
---------------

SELECT a.tablespace_name,sum(a.bytes/1024/1024) "Size_MB" , sum(a.bytes/1024/1024 - b.free_size_MB) "Used_MB"
 FROM dba_data_files a, 
 (SELECT file_id, SUM(bytes)/1024/1024 free_size_MB
 FROM dba_free_space b GROUP BY file_id) b
 WHERE a.file_id=b.file_id
 group by a.tablespace_name
 ORDER BY  a.tablespace_name;


----------------------------------------------------------------------------------------------
select aa.TABLESPACE_NAME , round(SUM(aa.bytes)/1024/1024/1024,2) as size_GB , round(cc.free_size_GB,2) as free_size_GB , round(SUM(aa.bytes)/1024/1024/1024- cc.free_size_GB,2)  as used_GB 
FROM dba_data_files aa ,(select TABLESPACE_NAME , SUM(bytes)/1024/1024/1024 as free_size_GB from dba_free_space  GROUP BY TABLESPACE_NAME ) cc 
where aa.TABLESPACE_NAME = cc.TABLESPACE_NAME
GROUP BY aa.TABLESPACE_NAME , cc.free_size_GB 
order by  aa.TABLESPACE_NAME
----------------------------------------------------------------------------------------------
select total.tablespace_name tsname, round((1-nvl(sum(free.bytes),0)/total.bytes)*100)  pctusd 
from (select tablespace_name,    sum(bytes) bytes from    dba_data_files  group by tablespace_name)  total,  dba_free_space  free 
where  total.tablespace_name = free.tablespace_name(+) /*and total.tablespace_name = 'USERS'*/
group by total.tablespace_name,  total.bytes 
order by   (1-nvl(sum(free.bytes),0)/total.bytes)*100  asc 
----------------------------------------------------------------------------------------------
SELECT /* + RULE */
    df.tablespace_name AS "Tablespace"
    ,df.bytes / (1024 * 1024 * 1024) AS "Size (GB)"
    ,Trunc(fs.bytes / (1024 * 1024 * 1024)) AS "Free (GB)",
    100-((fs.bytes/df.bytes)*100) as "%usage"
FROM (
    SELECT tablespace_name
        ,Sum(bytes) AS bytes
    FROM dba_free_space
    GROUP BY tablespace_name
    ) fs
    ,(
        SELECT tablespace_name
            ,SUM(bytes) AS bytes
        FROM dba_data_files
        GROUP BY tablespace_name
        ) df
WHERE fs.tablespace_name = df.tablespace_name
ORDER BY 4 DESC
-----------------------------------------------------------------------------------------------


select segment_name,segment_type,round(sum(bytes)/1024/1024/1024)
from dba_segments 
where tablespace_name='TS_ROCRAUSG_DAT01'
group by segment_name,segment_type
order by 3 desc,1
-----------------------------------------------------------------------------------------------------



SELECT sum(a.bytes/1024/1024/1024) "Size_GB" , sum(a.bytes/1024/1024/1024 - b.free_size_GB) "Used_GB"
 FROM dba_data_files a, 
 (SELECT file_id, SUM(bytes)/1024/1024/1024 free_size_GB
 FROM dba_free_space b GROUP BY file_id) b
 WHERE a.file_id=b.file_id



SELECT  sum(a.bytes/1024/1024/1024 - b.free_size_GB) "Used GB"
 FROM dba_data_files a, 
 (SELECT file_id, SUM(bytes)/1024/1024/1024 free_size_GB
 FROM dba_free_space b GROUP BY file_id) b
 WHERE a.file_id=b.file_id and a.TABLESPACE_NAME like'FCSTE_IND%'



SELECT  sum(a.bytes/1024/1024/1024 - b.free_size_GB) "Used GB"
 FROM dba_data_files a, 
 (SELECT file_id, SUM(bytes)/1024/1024/1024 free_size_GB
 FROM dba_free_space b GROUP BY file_id) b
 WHERE a.file_id=b.file_id and a.TABLESPACE_NAME like'FCSTE_DATA%'


---------------------------------------------------------------------------------------------



SELECT ts.tablespace_name,
       round(size_info.megs_alloc/1024,2) "Total_GB",
       round(size_info.megs_free/1024,2) "Free_GB",
       round(size_info.megs_used/1024,2) "Used_GB",
       round(size_info.pct_used,2)||'%' "Used of max",
       round(size_info.MAX/1024,2) "Max Size",
       ts.status,
       ts.contents,
       ts.logging,
       ts.extent_management,
       ts.allocation_type,
       ts.block_size,
       ts.segment_space_management,
       ts.force_logging,
       ts.bigfile,
       ts.def_tab_compression
       
  FROM (SELECT a.tablespace_name,
               ROUND (a.bytes_alloc / 1024 / 1024) megs_alloc,
               ROUND (NVL (b.bytes_free, 0) / 1024 / 1024) megs_free,
               ROUND ( (a.bytes_alloc - NVL (b.bytes_free, 0)) / 1024 / 1024)
                  megs_used,
               ROUND ( (NVL (b.bytes_free, 0) / a.bytes_alloc) * 100)
                  Pct_Free,
               100 - ROUND ( (NVL (b.bytes_free, 0) / a.bytes_alloc) * 100)
                  Pct_used,
               ROUND (maxbytes / 1048576) MAX
          FROM (  SELECT f.tablespace_name,
                         SUM (f.bytes) bytes_alloc,
                         SUM (
                            DECODE (f.autoextensible,
                                    'YES', f.maxbytes,
                                    'NO', f.bytes))
                            maxbytes
                    FROM dba_data_files f
                GROUP BY tablespace_name) a,
               (  SELECT f.tablespace_name, SUM (f.bytes) bytes_free
                    FROM dba_free_space f
                GROUP BY tablespace_name) b
         WHERE a.tablespace_name = b.tablespace_name(+)
        UNION ALL
          SELECT h.tablespace_name,
                 ROUND (SUM (h.bytes_free + h.bytes_used) / 1048576) megs_alloc,
                 ROUND (
                      SUM (
                         (h.bytes_free + h.bytes_used) - NVL (p.bytes_used, 0))
                    / 1048576)
                    megs_free,
                 ROUND (SUM (NVL (p.bytes_used, 0)) / 1048576) megs_used,
                 ROUND (
                      (  SUM (
                              (h.bytes_free + h.bytes_used)
                            - NVL (p.bytes_used, 0))
                       / SUM (h.bytes_used + h.bytes_free))
                    * 100)
                    Pct_Free,
                   100
                 - ROUND (
                        (  SUM (
                                (h.bytes_free + h.bytes_used)
                              - NVL (p.bytes_used, 0))
                         / SUM (h.bytes_used + h.bytes_free))
                      * 100)
                    pct_used,
                 ROUND (
                    SUM (
                         DECODE (f.autoextensible,
                                 'YES', f.maxbytes,
                                 'NO', f.bytes)
                       / 1048576))
                    MAX
            FROM sys.v_$TEMP_SPACE_HEADER h,
                 sys.v_$Temp_extent_pool p,
                 dba_temp_files f
           WHERE     p.file_id(+) = h.file_id
                 AND p.tablespace_name(+) = h.tablespace_name
                 AND f.file_id = h.file_id
                 AND f.tablespace_name = h.tablespace_name
        GROUP BY h.tablespace_name) size_info,
       sys.dba_tablespaces ts,
       sys.dba_tablespace_groups tsg
 WHERE     ts.tablespace_name = size_info.tablespace_name
       AND ts.tablespace_name = tsg.tablespace_name(+)
       order by &col &desc








