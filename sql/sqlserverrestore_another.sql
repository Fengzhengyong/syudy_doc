declare @dumpfile varchar(50)
declare @msg varchar(70)
   select @dumpfile = 'c:\backup\DataSample_bak_20170718161443.BAK'
   select @msg=convert(char(26),getdate(),9)
   print @msg
 
----同一个备份文件还原成不同名称数据库  
RESTORE DATABASE DataSample1
   FROM disk=@dumpfile
   WITH RECOVERY,
   MOVE 'DataSample' TO 'D:\MyData\DataSample1.mdf', 
   MOVE 'DataSample_Log' TO 'D:\MyData\DataSample1_Log.ldf'
 
if (@@ERROR <> 0 )
begin
   select @msg=convert(char(26),getdate(),9)+'-----还原数据失败或出现异常'
   print @msg
end
else
begin
   select @msg=convert(char(26),getdate(),9)+'-----数据库还原完毕'
   print @msg
end