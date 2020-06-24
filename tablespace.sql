SET FEEDBACK OFF ;
set pagesize 100;
set linesize 200;
set echo off;
set heading on;
SET VERIFY OFF ;
set markup html on spool on entmap off -
     head '-
     <style type="text/css"> -
        table { background: #eee; font-size: 90%; } -
        th { background: #ccc; align=center} -
        td { padding: 0px;  text-align:center; vertical-align:middle;font-size:10px;font-weight: bold; } -
     </style>' -
     body 'text=black bgcolor=fffffff align=left' -
     table 'align=center width=99% border=3 bordercolor=black bgcolor=white';

conn  user/password@DB
col sysdt noprint new_value sysdt
SELECT TO_CHAR(SYSDATE, 'dd-mm-yyyy') sysdt FROM DUAL;

spool D:\TBS_Daily_Checks\tablespacesResult_&sysdt..html append;

select '<font size=2>
' ||  '&_connect_identifier' ||'</font>
' " Connect Identifier" ,'<font size=2>
' || instance_name ||'</font>
' " DB Name" ,
'<font size=2>
' || to_char(sysdate,'DD.MON.YYYY HH24:MI:SS') ||'</font>
' "Current Time" from V$instance;

	select "Tablespace","Used MB","Free MB",
		case
		 when "Used %" > 90 then '<p style="color: white; background-color: #666666">'||"Used %"||'</p>'
		 else to_char("Used %")
		 end as "USED %"
		 from (
		select  nvl(b.tablespace_name,
                                     nvl(a.tablespace_name,'UNKNOWN')) "Tablespace",
                                     kbytes_alloc "Allocated MB",
                                     kbytes_alloc-nvl(kbytes_free,0) "Used MB",
                                     nvl(kbytes_free,0) "Free MB",
                                     round((((kbytes_alloc-nvl(kbytes_free,0))/kbytes_alloc)*100),2) "Used %"
                                from ( select sum(bytes)/1024/1024 Kbytes_free,
                                              max(bytes)/1024/1024 largest,
                                              tablespace_name
                                         from sys.dba_free_space
										 where tablespace_name not like '%UNDO%'
                                        group by tablespace_name ) a,
                                     ( select sum(bytes)/1024/1024 Kbytes_alloc,
                                              tablespace_name
                                         from sys.dba_data_files
										 where tablespace_name not like '%UNDO%'
                                        group by tablespace_name )b
                               where a.tablespace_name (+) = b.tablespace_name
                               order by 1
							   )  order by 4 desc ;


spool off;

conn  user/password@DB
spool D:\TBS_Daily_Checks\tablespacesResult_&sysdt..html append;

select '<font size=2>
' ||  '&_connect_identifier' ||'</font>
' " Connect Identifier" ,'<font size=2>
' || instance_name ||'</font>
' " DB Name" ,
'<font size=2>
' || to_char(sysdate,'DD.MON.YYYY HH24:MI:SS') ||'</font>
' "Current Time" from V$instance;

	select "Tablespace","Used MB","Free MB",
		case
		 when "Used %" > 90 then '<p style="color: white; background-color: #666666">'||"Used %"||'</p>'
		 else to_char("Used %")
		 end as "USED %"
		 from (
		select  nvl(b.tablespace_name,
                                     nvl(a.tablespace_name,'UNKNOWN')) "Tablespace",
                                     kbytes_alloc "Allocated MB",
                                     kbytes_alloc-nvl(kbytes_free,0) "Used MB",
                                     nvl(kbytes_free,0) "Free MB",
                                     round((((kbytes_alloc-nvl(kbytes_free,0))/kbytes_alloc)*100),2) "Used %"
                                from ( select sum(bytes)/1024/1024 Kbytes_free,
                                              max(bytes)/1024/1024 largest,
                                              tablespace_name
                                         from sys.dba_free_space
										 where tablespace_name not like '%UNDO%'
                                        group by tablespace_name ) a,
                                     ( select sum(bytes)/1024/1024 Kbytes_alloc,
                                              tablespace_name
                                         from sys.dba_data_files
										 where tablespace_name not like '%UNDO%'
                                        group by tablespace_name )b
                               where a.tablespace_name (+) = b.tablespace_name
                               order by 1
							   )  order by 4 desc ;


spool off;



spool D:\TBS_Daily_Checks\tablespacesResult_&sysdt..html append;
set heading off ;
select '<font size=4> <b>' ||'Reviewed by'||' </b> </font>'  from dual ;
select '<font size=2> <i>' ||'Name :'||' </i> </font>' , '<td width="70%">'||chr(32)||'</td>' from dual 
union
select '<font size=2> <i>' ||'Signature:'||' </i> </font>' , '<td width="70%">'||chr(32)||'</td>' from dual ;

select '<font size=4> <b>' ||'Approved by'||' </b> </font>'  from dual ;
select '<font size=2> <i>' ||'Name :'||' </i> </font>' , '<td width="70%">'||chr(32)||'</td>' from dual 
union
select '<font size=2> <i>' ||'Signature:'||' </i> </font>' , '<td width="70%">'||chr(32)||'</td>' from dual ;
spool off ;
exit