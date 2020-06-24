SELECT tablespace_name, 
Sum(bytes)/1024/1024 AS total_size_mb
FROM dba_segments
WHERE owner = Upper('&User_Name')
GROUP BY owner, rollup(tablespace_name);
