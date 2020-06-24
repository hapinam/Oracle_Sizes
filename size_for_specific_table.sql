SELECT owner, segment_name, bytes/1024/1024 mb
  FROM dba_segments
WHERE owner = 'SCHEMA_OWNER'
   AND segment_name like '%TABLE_NAME%' 
ORDER BY mb asc;
