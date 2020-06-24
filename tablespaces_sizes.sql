select substr(tablespace_name,1,15) "tbs",file_name "auto extend data file",(MAXBYTES/1024)/1024 "MAXMEGA",
increment_by*b.block_size/1024/1024 "incr. /MB",(b.CREATE_BYTES/1024)/1024 "CREATED MEGA",(a.BYTES/1024)/1024 "MB REACHED",b.block_size
from dba_data_files a,V$DATAFILE b
where b.FILE#=a.FILE_ID
union
select substr(tablespace_name,1,15) "tbs",file_name "auto extend data file",(MAXBYTES/1024)/1024 "MAXMEGA",
increment_by*b.block_size/1024/1024 "incr. /MB",(b.CREATE_BYTES/1024)/1024 "CREATED MEGA",(a.BYTES/1024)/1024 "MB REACHED",b.block_size
from dba_temp_files a,V$tempfile b
where b.FILE#=a.FILE_ID;

------------------------------------------------------------------------------------------------------------------------------------------------
################################################################################################################################################
------------------------------------------------------------------------------------------------------------------------------------------------

select t.tablespace_name "Tablespace",
decode(t.status, 'ONLINE', t.status, nls_initcap(t.status)) "Status",
       to_char(tsa.bytes / 1024/1024, '999G999G990')  "Size (M)",
       to_char((tsa.bytes - decode(tsf.bytes, null, 0, tsf.bytes))
         / 1024/1024, '999G999G990')  "Used (M)",
       to_char(decode(tsf.bytes, null, 0, tsf.bytes)
         / 1024/1024, '999G999G990')  "Remain (M)",
       to_char((1 - decode(tsf.bytes, null, 0,tsf.bytes)
         / tsa.bytes) * 100, '990')  "% Used"
        from sys.dba_tablespaces t, sys.sm$ts_avail tsa, sys.sm$ts_free tsf
        where t.tablespace_name = tsa.tablespace_name
        and   t.tablespace_name = tsf.tablespace_name (+)
        order by 1, t.status, t.tablespace_name;

		
------------------------------------------------------------------------------------------------------------------------------------------------
################################################################################################################################################
------------------------------------------------------------------------------------------------------------------------------------------------		
	
select t.owner,t.tablespace_name,(sum(nvl(t.bytes,0))/1024)/1024 "total MB allocated",
((sum(nvl(t.bytes,0))/1024) * 100)/(a.BYTES/1024) "%"
from dba_segments t,dba_data_files a
where t.tablespace_name=a.tablespace_name
group by t.owner,t.tablespace_name,(a.BYTES/1024)
order by t.owner,t.tablespace_name;