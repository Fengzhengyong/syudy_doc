1. 服务器搭建，配置：办公网，8C，8G，400G，centos7.2

2. 拉取镜像，/etc/yum.repos.d目录下，包括CentOS-kingdee.net.repo，docker.repo，备份路径在172.18.2.169上面的/var/ftp/bigdata/docker_repo目录下

3. 清除yum缓存，yum makecache

4. 安装docker，svnadmin。 
	yum install docker-engine
	yum install subversion
	
5. 启动docker，systemctl start docker

6. 拉取subversion_ldap.tar镜像，备份路径在172.18.2.169上面的/var/ftp/bigdata目录下，并进行导入
	docker load < subversion_ldap.tar
	
7. 建立对应的CSVN组，/etc/passwd|grep csvn
	groupadd –g 5000 k3cloud_bbc
	useradd –d /home/csvn –s /bin/sh –u 33 csvn      [svn用户]
	useradd -d /home/k3cy -s /bin/sh k3cy			 [研发用户]

	根据相应的库建立对应的组
	

8.将makedocker拷贝至/var/svn_docker目录
	

9. 通过create_docker.sh建立相应容器，通过createrepo.sh建立相应库

10. 通过docker ps -a获取对应容器ID,之后启动对应容器，docker start ID


备份还原
11. ftp获取备份包，备份路径在172.18.2.169上面的/var/ftp/bigdata/backup_docker.tar.gz，
注意放置在/var目录下解压，根目录下无空间，由于tar.gz无法指定解压路径，解压后需要将/var/var/backup/svn_docker路径剪切到/var/svn_docker


12. 检查是否有相关容器，如不存在，运行对应create_docker脚本创建容器。更改文件夹权限，并将对应conf文件还原完整，启动对应容器，即可测试访问

13. 查询容器ID是否有变化，启动即可

相关命令：

	docker ps [-a]       	[查看正在运行的容器(参数-a可现实所有)]
	docker start ID		 	[启动对应ID的容器]
	service docker start 	[启动docker服务]