Allocated:
----------

select 
( select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
( select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
( select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
( select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile) "Size in GB"
from
dual;






Free:
-----

select 
( select sum(bytes)/1024/1024/1024 data_size from dba_free_space )+
( select sum(free_space)/1024/1024/1024 data_size from dba_temp_free_space ) "Size in GB"
from
dual;
