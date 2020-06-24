--To keep a history of how database is growing you can create a table that records for example every week the database size. The following procedure does not take into account the UNDO tablespace and TEMPORARY tablespace, only real data and indexes. 

--Create the table for database size history
create table db_space_hist (
    timestamp    date,
    total_space_in_gb  number(8),
    used_space_in_gb   number(8),
    free_space_in_gb   number(8),
        pct_inuse    number(5,2),
        num_db_files number(5)
);

--Create the procedure db_space_history
CREATE OR REPLACE PROCEDURE db_space_history AS
BEGIN
   INSERT INTO db_space_hist 
    SELECT SYSDATE, total_space,
        total_space-NVL(free_space,0) used_space,
        NVL(free_space,0) free_space,
        ((total_space - NVL(free_space,0)) / total_space)*100 pct_inuse,
        num_db_files
 FROM ( SELECT SUM(bytes)/1024/1024/1024 free_space
        FROM   sys.DBA_FREE_SPACE WHERE tablespace_name NOT LIKE '%UNDO%') FREE,
      ( SELECT SUM(bytes)/1024/1024/1024 total_space,
               COUNT(*) num_db_files
        FROM   sys.DBA_DATA_FILES WHERE tablespace_name NOT LIKE '%UNDO%') FULL;
   COMMIT;
END;
/


--Create the job that runs once in a week

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DB_SPACE_HISTORY_JOB'
      ,start_date      => TO_TIMESTAMP_TZ('2018/01/13 02:00:00.000000 +02:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'freq=weekly; byhour=0; byminute=0; bysecond=0;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN DB_SPACE_HISTORY(); end;'
      ,comments        => 'Job Weekly Spaces'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_RUNS);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DB_SPACE_HISTORY_JOB'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DB_SPACE_HISTORY_JOB');
END;
/

/*
Monitor how things going on periodically:
select * from db_space_hist order by timestamp desc;
Alternative:How the database size increased in GBytes per month for the last year.
SELECT TO_CHAR(creation_time, 'RRRR Month') "Month", 
round(SUM(bytes)/1024/1024/1024) "Growth in GBytes" 
FROM sys.v_$datafile 
WHERE creation_time > SYSDATE-365 
GROUP BY TO_CHAR(creation_time, 'RRRR Month');

Month          Growth in GBytes
-------------- ----------------
2008 December              1331
2008 November               779
2008 October                447
2009 April                  797
2009 August                 344
2009 February               505
2009 January                443
2009 July                   358
2009 June                   650
2009 March                  452
2009 May                   1787
2009 October                255
2009 September              158

As you can see from the last query the database increased its size for the month: 2009 October 255 GBytes
*/