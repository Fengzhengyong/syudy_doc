@echo off
echo 开始还原数据库
net start "mssqlserver"
osql -U sa -P 123456 -i c:\backup\sqlserverrestore.sql -o c:\backup\sqlserverrestore.out
echo 还原数据库完成
pause