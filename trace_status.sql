select
      [Status] =
      case tr.[status]
            when 1 THEN 'Running'
            when 0 THEN 'Stopped'
      end
      ,[Default] =
            case tr.is_default
                  when 1 THEN 'System TRACE'
                  when 0 THEN 'User TRACE'
            end
       ,[login_name] = coalesce(se.login_name,se.login_name,'No reader spid')
      ,[Trace Path] = coalesce(tr.[Path],tr.[Path],'OLE DB Client Side Trace')
      from sys.traces tr
            left join sys.dm_exec_sessions se on tr.reader_spid = se.session_id

select * from  sys.traces

/*
0 = Stop Trace
1 = Start Trace
2 = Close/Delete Trace
*/
EXEC sp_trace_setstatus 4,0 -- Stopa Profile
EXEC sp_trace_setstatus 4,2 -- Close Profile
