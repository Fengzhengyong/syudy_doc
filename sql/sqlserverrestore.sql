declare @dumpfile varchar(50)
declare @msg varchar(70)
   select @dumpfile = 'c:\backup\DataSample_bak_20170718145556.BAK'
   select @msg=convert(char(26),getdate(),9)
   print @msg
 
restore DATABASE DataSample from disk=@dumpfile
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