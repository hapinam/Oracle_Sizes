select name,round(total_mb/1024) total_GB,round(free_mb/1024) free_GB,round(USABLE_FILE_MB/1024) "Usable_GB", round(100-free_mb/total_mb*100)||'%' used,type as "Redundancy"
from v$asm_diskgroup;



select 
   d.group_number,
   g.name,
   d.mount_status,
   d.header_status,
   d.mode_status,
   d.state,
   d.total_mb,
   d.free_mb,
   d.name,
   d.path,
   d.label 
from 
   v$asm_disk d , v$asm_diskgroup g
where d.group_number=g.group_number;