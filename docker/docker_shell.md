```shell
docker ps [-a]       	[查看正在运行的容器(参数-a可现实所有)]

docker start ID		 	[启动对应ID的容器]

service docker start 	[启动docker服务]

docker inspect k3cy     [查看容器运行的相关数据]

docker inspect --format='{{.NetworkSettings.IPAddress}}' k3cy     [查看容器映射的IP]

docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'   [获取所有容器名称及其IP地址]

docker inspect --format '{{.Name}} {{.State.Running}}' NAMES   		[容器运行状态]

docker top NAMES		[查看进程信息]

docker port ID/NAMES   	[查看端口]

docker exec -it ID/NAMES ip addr  [远程执行命令查看IP和端口]
```

