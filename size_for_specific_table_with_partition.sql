SELECT owner, segment_name, PARTITION_name, bytes/1024/1024 mb, TABLESPACE_NAME
  FROM dba_segments
WHERE owner = 'SCHEMA_OWNER'
   AND segment_type in ('TABLE PARTITION','INDEX','TABLE')
   AND (segment_name like '%TABLE_NAME%')
ORDER BY segment_name,mb asc;