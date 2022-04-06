
##########################################
###### gpkrutil path
##########################################
##export GPKRUTIL=/data/gpkrutil
export GPKRUTIL="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export STATLOG=${GPKRUTIL}/statlog
export CRONLOG=${GPKRUTIL}/cronlog

##########################################
####### system alias 
##########################################
alias all='gpssh -f ${GPKRUTIL}/hostfile_all'
alias seg='gpssh -f ${GPKRUTIL}/hostfile_seg'
alias tails='ls  ${GPKRUTIL}/statlog/sys.202*.txt | tail -1 | xargs tail -f'


##########################################
####### Database alias for Greenplum 6 
###########################################

###########################
####### DB session 
###########################
alias qq='psql -c " SELECT datname, now()-query_start as duration_time, usename, client_addr, waiting, pid, sess_id, rsgname from pg_stat_activity WHERE state not like '\''%idle%'\'' ORDER BY waiting, duration_time desc;"'
alias qqit='psql  -c "SELECT datname, substring(backend_start,1,19) as backend_time, now()-query_start as duration_time, usename, client_addr, waiting, waiting_reason, pid, sess_id, rsgname, substring(query,1,60) FROM pg_stat_activity as query_string WHERE state <> '\''idle'\'' ORDER BY waiting, duration_time desc;"'
alias cq='psql -c "SELECT now()-query_start, pid, usename, sess_id, query from pg_stat_activity where state not like '\''%idle%'\'' order by 1 desc;"'
alias is='psql -c " SELECT now()-query_start, usename, pid, sess_id, query from pg_stat_activity where state like '\''idle'\'' order by 1 desc;"'
alias it='psql  -c "SELECT now()-query_start, usename, pid, sess_id, query FROM pg_stat_activity where trim(query) like '\''%in transaction'\'' ORDER BY 1 DESC;"'
alias tq='psql -c "SELECT count(*) from pg_stat_activity;"'


###########################
####### locks 
###########################
alias lt='psql  -c "SELECT distinct w.locktype, w.relation::regclass AS relation, w.mode, w.pid as waiting_pid, other.pid as running_pid, w.gp_segment_id FROM pg_catalog.pg_locks AS w JOIN pg_catalog.pg_stat_activity AS w_stm ON (w_stm.pid = w.pid) JOIN pg_catalog.pg_locks AS other ON ((w.DATABASE = other.DATABASE AND w.relation = other.relation) OR w.transactionid = other.transactionid) JOIN pg_catalog.pg_stat_activity AS other_stm ON (other_stm.pid = other.pid) WHERE NOT w.granted and w.pid <> other.pid;"'
alias locks='psql -c " SELECT pid, relname, locktype, mode, a.gp_segment_id from pg_locks a, pg_class where relation=oid and relname not like '\''pg_%'\'' order by 3;"'

###########################
###### DB management 
###########################
#
alias na='psql -c "SELECT count(relname) from pg_class where reltuples=0 and relpages=0 and relkind='\''r'\'' and relname not like '\''t%'\'' and relname not like '\''err%'\'';" '
alias nan='psql -AXtc "SELECT '\''analyze '\''||nspname||'\''.'\''||relname||'\'';'\'' from pg_class c, pg_namespace nc where nc.oid = c.relnamespace and c.reltuples=0 and c.relpages=0 and c.relkind='\''r'\'' and c.relname not like '\''t%'\'' and c.relname not like '\''err%'\'';"'
alias ts='psql -c "select n.nspname from pg_namespace n where nspname not in (select '\''pg_temp_'\''||sess_id from pg_stat_activity) and nspname  like '\''pg_temp%'\'';"'
alias bt='psql -c "select bdinspname schema_nm, bdirelname tb_nm, bdirelpages*32.0/1024.0 real_size_mb, bdiexppages*32.0/1024.0 exp_size_mb from gp_toolkit.gp_bloat_diag where bdirelpages*32.0/1024.0 > 100;" '
alias reorg='psql -AXtc "select '\''ALTER TABLE '\''||bdinspname||'\''.'\''||bdirelname||'\'' SET WITH (REORGANIZE=TRUE); '\'' qry from gp_toolkit.gp_bloat_diag where bdirelpages*32/1024 > 10 ;" '
alias wk='psql  -c " select * from workfile.gp_workfile_usage_per_segment where size > 1;"'
alias pgoption='PGOPTIONS="-c gp_session_role=utility" psql -p 5432'
alias invalid='psql -c "SELECT * from gp_configuration where valid='\''f'\'';"'

###########################
####### resource queue
###########################
alias rqs='psql  -c " select rsqname, rsqcountlimit cntlimit, rsqcountvalue cntval, rsqcostlimit costlimit, rsqcostvalue costval, rsqmemorylimit memlimit, rsqmemoryvalue memval, rsqwaiters waiters, rsqholders holders from gp_toolkit.gp_resqueue_status;"'
alias rqsh='psql -c " SELECT a.rsqname,a.rsqcountlimit,a.rsqcountvalue,a.rsqwaiters,a.rsqholders,a.rsqcostlimit,a.rsqcostvalue,a.rsqmemorylimit,a.rsqmemoryvalue,b.rsqignorecostlimit,b.rsqovercommit,c.ressetting FROM gp_toolkit.gp_resqueue_status a INNER JOIN pg_resqueue b ON b.rsqname = a.rsqname INNER JOIN pg_resqueue_attributes c ON c.rsqname = a.rsqname AND c.restypid = 5 ORDER BY 1;"'
alias rss='psql -c " select a.rsqname, a.rsqcountlimit as countlimit, a.rsqcountvalue as countvalue, a.rsqwaiters as waiters, a.rsqholders as running ,a.rsqcostlimit as costlimit, a.rsqcostvalue as costvalue, b.rsqignorecostlimit as ignorecostlimit, b.rsqovercommit as overcommit from pg_resqueue_status a, pg_resqueue b where a.rsqname =b.rsqname order by 1;"'
alias rq='psql -c " select * from pg_resqueue order by 1;"'

###########################
####### resource group
###########################
alias rga='psql -c "SELECT rolname, rsgname FROM pg_roles, pg_resgroup  WHERE pg_roles.rolresgroup=pg_resgroup.oid;"'
alias rg='psql -c "SELECT * FROM gp_toolkit.gp_resgroup_status_per_host;"'
alias rgss='psql -c "SELECT * FROM gp_toolkit.gp_resgroup_status_per_segment;"'
alias rgd='psql -c "SELECT * FROM gp_toolkit.gp_resgroup_status;"'
alias rss='psql -c “SELECT rs.rsgname,rc.concurrency,rs.num_running,rs.num_queueing,rs.num_queued,rs.num_executed,rs.total_queue_duration,rs.cpu_avg,rc.cpu_rate_limit,rc.memory_limit FROM (SELECT rsgname,num_running,num_queueing,num_queued,num_executed,total_queue_duration,round(avg(cpu_value::float)) as cpu_avg FROM (SELECT rsgname,num_running,num_queueing,num_queued,num_executed,total_queue_duration,row_to_json(json_each(cpu_usage::json))->>'\''key'\'' as cpu_key,row_to_json(json_each(cpu_usage::json))->>'\''value'\'' as cpu_value FROM gp_toolkit.gp_resgroup_status order by rsgname) z WHERE z.cpu_key::int > -1 GROUP BY rsgname, num_running, num_queueing, num_queued, num_executed, total_queue_duration ORDER BY 2 desc, 7 desc) as rs, gp_toolkit.gp_resgroup_config as rc WHERE rs.rsgname = rc.groupname;”'

###########################
####### pgbouncer 
###########################
alias pgbc='psql -p 6543 pgbouncer -c "show clients"'
alias pgbs='psql -p 6543 pgbouncer -c "show sockets"'
alias pgbf='psql -p 6543 pgbouncer -c "show config"'
alias pgbp='psql -p 6543 pgbouncer -c "show pools"'
alias pgbreload='psql -p 6543 pgbouncer -c “RELOAD;"'
alias pgbstart='/usr/local/greenplum-db/bin/pgbouncer -d /data/master/pgbouncer/pgbouncer.ini'
alias pgbstop='psql -p 6543 pgbouncer -c "SHUTDOWN;"'


###########################
####### pxf 
###########################
alias pxfstatus='/usr/local/greenplum-db/pxf/bin/pxf cluster status'
alias pxfstart='/usr/local/greenplum-db/pxf/bin/pxf cluster start'
alias pxfstop='/usr/local/greenplum-db/pxf/bin/pxf cluster stop'
alias pxfsync='/usr/local/greenplum-db/pxf/bin/pxf cluster sync'
alias pxfinit='/usr/local/greenplum-db/pxf/bin/pxf cluster init'
alias pxfreset='/usr/local/greenplum-db/pxf/bin/pxf cluster reset'


########################################
#GP_BACKUP_DIR=/data1/backup
#GP_BACKUP_LOG_DIR=/data1/dba/gpAdminLogs
#KEEP_BACKUP_DAYS=7
#KEEP_LOG_DAYS=30
#LOG_PATH=/data1/dba/logs

#NMONLOGDIR=/data1/dba/backup/nmon

#STATLOGBACKUPDIR=/data/backup/statlog
#STATLOG_VACUUMDIR=/data/dba/utilities/log

#SYSTEMLOG_DIR=/data1/master/gpseg-1/gpperfmon/data/snmp
#VACUUMLOGDIR=/data1/utilities/log

#UTILLOG=/data1/util_log
#GP_ADMINLOG=/data1/dba/gpAdminLogs
