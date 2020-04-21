### sqlserver数据库附加分离备份还原命令

--获取所有数据库的名称

```
select [name] from master.dbo.sysdatabases where [name]='master'
```

--判断数据库是否存在

```
if exists(select [name] from master.dbo.sysdatabases where [name]='master')
    begin
     select 1;
    end

 else
    begin
    select 0;
    end
```

--分离数据库-----要先获取所有的数据库

```
if exists(select [name] from master.dbo.sysdatabases where [name]='zuobiao')
    

    begin
    exec sp_detach_db 'zuobiao'
     select 1;
    end

 else
    begin
    select 0;
    end
```

--附加数据库-------要判断要附加的数据库是否存在

```
if exists(select [name] from master.dbo.sysdatabases where [name]='zuobiao')
    

    begin
     select 0;
    end

 else
    begin
    exec sp_attach_db @dbname='zuobiao'
                      ,@filename1='D:\Program Files\SQL Server\MSSQL.1\MSSQL\Data\zuobiao.mdf'
                      ,@filename2='D:\Program Files\SQL Server\MSSQL.1\MSSQL\Data\zuobiao_log.LDF'
    select 1;
    end
```

---备份数据库

```
use master 
go
backup database demo to disk='d:\database\demo.bak'

--还原数据库
use master 
go
restore database demo 
from disk='d:\database\demo.bak' 
with replace
```


