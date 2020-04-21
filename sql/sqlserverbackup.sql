DECLARE @name varchar(50)
DECLARE @datetime char(14)
DECLARE @path varchar(255)
DECLARE @bakfile varchar(255)
set @name='DataSample'
set @datetime=CONVERT(char(8),getdate(),112) + REPLACE(CONVERT(char(8),getdate(),108),':','')
set @path='c:\backup\'
set @bakfile=@path+''+@name+'_'+'bak_'+@datetime+'.BAK'
backup database @name to disk=@bakfile with name=@name
go