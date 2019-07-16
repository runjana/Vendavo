


begin try
restore verifyonly from disk='D:\MSSQL\Backup\BANKSMART_N.bak'
EXEC msdb.dbo.sp_send_dbmail @profile_name='test',
@recipients='ranjana.ghimire@f1soft.com',
@subject='Test message',
@body='Backup taken successfully'
end try

begin catch
EXEC msdb.dbo.sp_send_dbmail @profile_name='test',
@recipients='ranjana.ghimire@f1soft.com',
@subject='Test message',
@body='Backup taken successfully'
end catch
