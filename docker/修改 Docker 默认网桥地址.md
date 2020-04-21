# 					修改 Docker 默认网桥地址

原因： docker映射网段172.17.\*.\* 与内部网段冲突，导致内部无法访问，需要修改docker映射IP

1. `docker network inspect bridge`    [查看docker默认使用的网桥]

    `route -n`    [查看网卡 docker0 是否存在] 

2. `service docker stop `    [停止当前docker服务]

3. ` yum install -y bridge-utils `   [安装网桥创建工具brctl ]

4. 创建新的网桥：

    ```shell
    brctl addbr bridge0
    ip addr add 10.0.129.1/24 dev bridge0
    ip link set dev bridge0 up
    ```

5. ` ip addr show bridge0 `   [确认网桥信息]

6. 修改配置文件： /etc/default/docker 或 /etc/sysconfig/docker 

    ```shell
    当docker配置文件不存在时，需要自行新建 /etc/default/docker
    在/usr/lib/systemd/system/docker.service 中添加相应配置
    EnvironmentFile=-/etc/default/docker #添加配置文件（-代表ignore error）
    “ExecStart=”  最后添加 $DOCKER_OPTS
    
    vi /etc/default/docker
    DOCKER_OPTS="-b=bridge0"
    ```

7. ` systemctl daemon-reload ` [重载配置文件]

8. ` systemctl restart docker ` [重启docker服务]

9. ` systemctl status docker ` [查看docker状态]

10. ` route  -n` [检查网桥状态]

11. 删除不再使用的网桥：

     ```shell
     ip link set dev docker0 down
     
     brctl delbr docker0
     ```

12. 添加自启动文件`brctl_bridge.sh`：

      ```shell
      brctl addbr bridge0
      ip addr add 10.0.129.1/24 dev bridge0
      ip link set dev bridge0 up 
      ```


12. 添加到自启动配置中： 通过在/etc/rc.local文件中添加可执行语句（如 sh /opt/brctl_bridge.sh &） 

