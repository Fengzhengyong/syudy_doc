@echo off
set path=%path%;C:\Program Files (x86)\Microsoft SQL Server\80\Tools\Binn
echo 数据库备份开始
osql.exe -S 127.0.0.1 -U sa -P 123456 -i sqlserverbackup.sql -o c:\backup\sqlserverbackup.out
echo 数据库备份完成
pause