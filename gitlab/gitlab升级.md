## 							`gitlab`版本升级流程

```
升级须知：gitlab在升级时需要将版本升级到本版本最高，如8.0.4-->8.17.8后才能进行大版本的升级。且在升级前必须做好数据和配置文件的备份，最好是在每次版本升级以后都进行数据访问和备份，以保证数据不会出现问题。如果升级失败，也可以及时进行版本回退，甚至重装至初始版本，然后进行数据恢复。
```

> ```bash
> # 官方规定升级路线（[https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations]）
> ```

> 环境： `CentOS release 6.6（Linux version 2.6.32-504.el6.x86_64）`
>
> 此次版本升级：`8.0.4 --> 8.17.8 --> 9.5.10 --> 10.8.7 -->11.8.10`

**重要：升级前需要将生产环境数据和配置文件备份，并在备份环境进行还原，保证数据的完整和可用性；否则一失足成千古恨**

> `/etc/gitlab/gitlab.rb` 				`git`配置文件
>
> `/var/opt/gitlab/nginx/conf`   	`nginx`配置文件
>
> `/etc/postfix/main.cfpostfix`  	邮件配置备份

------



### 升级流程：

1. ##### 下载指定版本的gitlab

   清华同方镜像： `https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el6/`

   官方：  `https://packages.gitlab.com/gitlab/gitlab-ce/ `

   下载对应版本的镜像进行升级

2. ##### 更新gitlab

   2.1 关闭`gitlab`服务

   ```shell
   gitlab-ctl stop unicorn										[停止工作线程]
   gitlab-ctl stop sidekiq										[停止数据库]
   gitlab-ctl stop nginx										[停止nginx]
   ```

   2.2 升级

   ```shell
   rpm -Uvh gitlab-ce-8.17.8-ce.0.el6.x86_64.rpm
   ```

   2.3 重新配置`gitlab`并重启

   ```shell
   gitlab-ctl reconfigure
   gitlab-rake gitlab:check SANITIZE=true						[检查配置文件的正确性]
   gitlab-ctl restart
```
   
   注：升级过程中可能会缺少某些依赖，`yum`安装即可

------



### 汉化补丁更新：

 1. 安装`gitlab`

    ```shell
    yum install -y git
    ```

2. 下载汉化包

   ```shell
   git clone https://gitlab.com/xhang/gitlab.git
   clone失败时直接访问下载zip文件
   ```

3. 查看汉化补丁版本

   ```shell
   a. cat gitlab/VERSION
   或
   b. unzip gitlab-v10.6.4-zh.zip
   ```

4. 停止`gitlab`

   ```shell
   gitlab-ctl stop
   ```

5. 切到汉化包路径，比较汉化包与原标签，并导出`patch`用的`diff`文件

   ```shell
   a.  cd /gitlab
   	git diff v10.6.4 v10.6.4-zh > 10.6.4-zh.diff
   或
   b. 	备份：/opt/gitlab/embedded/service/gitlab-rails文件
   ```

6. 将`diff`文件作为补丁进行更新

   ```shell
   a.  yum install patch -y
   	patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < 10.0.4-zh.diff
   或
   b.  cp -rf gitlab-11-8-stable-zh/* /opt/gitlab/embedded/service/gitlab-rails/
   ```

7. 重新配置`gitlab`

   ```shell
   gitlab-ctl reconfigure
   ```


------

#### 常用命令：

1. 查看当前版本：

   ```shell
   cat /opt/gitlab/embedded/service/gitlab-rails/VERSION
   ```

2. 备份

   ```shell
   gitlab-rake gitlab:backup:create
   ```

3. 指定时间戳的备份恢复(备份默认路径` /var/opt/gitlab/backups`)：

   ```shell
   gitlab-rake gitlab:backup:restore BACKUP=1500809139			[备份版本号不带时使用默认备份]
   ```

------

### 测试环境升级：

> ​	升级路线：` 8.0.4 -> 8.17.7 -> 9.5.10 -> 10.8.7 -> 11.8.10` 

1. 新建一个库作为一份正常环境，备份数据，防止升级失败损坏数据；

   ```shell
   gitlab-ctl stop unicorn										
   gitlab-ctl stop sidekiq										
   gitlab-ctl stop nginx
   gitlab-rake gitlab:backup:create
   ```

2. 开始版本升级（测试升级将直接升级至`11.8.0` 并检测数据的可用性） **在每一步安装成功后如果发现界面500，这是因为`redis`等程序还没完全启动，等一会儿访问就`ok`了。（一定保证数据可以正常访问方可执行下一步升级指令）** ：

   ```shell
   yum localinstall -y gitlab-ce-8.17.8-ce.0.el6.x86_64.rpm
   gitlab-ctl reconfigure
   gitlab-rake gitlab:check SANITIZE=true						[检查配置文件的正确性]
   gitlab-ctl restart
   
   yum localinstall -y gitlab-ce-9.5.10-ce.0.el6.x86_64.rpm
   yum localinstall -y gitlab-ce-10.8.7-ce.0.el6.x86_64.rpm 
   yum localinstall -y gitlab-ce-11.8.10-ce.0.el6.x86_64.rpm 
   ```

3. 一路比较顺畅，数据也无问题；中文补丁更新:

   ```shell
   git clone 网络问题失败
   手动下载https://gitlab.com/xhang/gitlab/-/tree/11-8-stable-zh  zip文件
   unzip gitlab-11-8-stable-zh.zip 
   备份：cp -r /opt/gitlab/embedded/service/gitlab-rails /home/gitlab-rails-11.8.0
   覆盖：cp -rf gitlab-11-8-stable-zh/* /opt/gitlab/embedded/service/gitlab-rails/
   重新配置： gitlab-ctl reconfigure
   重启： gitlab-ctl restart
   
   问题：gitlab-11-8-stable-zh版本为11.8.10；需要将11.8.0升级至11.8.10后再汉化
   yum localinstall -y gitlab-ce-11.8.10-ce.0.el6.x86_64.rpm 
   ```

4. 升级完成：暂无其他问题；

5. 总结：

   下载文件过于费时，需要提前将文件下载好并上传到服务器上；总体升级时间大约`2h`左右，每次升级完一个版本进行测试时需要边观察日志边测试可用性（`gitlab-ctl tail`）；如果某次升级出现问题且无法解决时，需要尽快将版本进行降级，并还原数据；保证环境的可用性

------

### `gitlab`版本降级（失败）

1. 停止服务

   ```shell
    gitlab-ctl stop 
   ```

2. 卸载当前版本：

   ```shell
   gitlab-ctl uninstall
   yum remove gitlab-ce
   gitlab-ctl cleanse #需要保留数据不执行该命令
   rm -rf /opt/gitlab #需要保留数据不执行该命令
   find / -name gitlab | xargs rm -rf    #删除所有包含gitlab的文件
   ```

3. 重新安装历史版本：

   ```shell
   yum localinstall -y gitlab-ce-8.0.4-ce.1.el6.x86_64.rpm
   gitlab-ctl reconfigure
   gitlab-rake gitlab:check SANITIZE=true
   gitlab-ctl restart
   ```

4. **结果：**

   降什么级，`postgresql`升级以后不会降，`redis`升级以后不会降；遍地是报错，有这时间，老老实实把`gitlab`卸载干净重装一份不好么   ?^_^?  现在知道数据备份是干嘛用的了吧 23333333333

------

##### 附：`Gitlab`清理

```
/var/opt/gitlab				[各类组件的配置和具体数据存放目录]
/etc/gitlab					[gitlab的配置目录，如数据存放目录，主线程数量等]
/opt/gitlab					[各类组件的可执行文件]
/var/log/gitlab				[日志目录]
```

##### 正式环境升级情况：

​	正式环境`data`数据约有`88G`左右，在实际升级过程中，数据升级时间比较长，建议留足时间

##### 数据迁移异常：

​	当发现启动出现异常或者报错时，检查数据是否正确，如果有显示为`down`的数据，则再次进行数据库关系升级，然后`reconfigure`：

```
gitlab-rake db:migrate:status			#查看数据升级状态
gitlab-rake db:migrate					#数据库关系升级
```



##### 建议：

> 在不影响业务的正常使用的情况下，建议每2个月左右进行一次版本升级，否则每次升级都需要跨很多大版本，比较费时且突发情况会很多。