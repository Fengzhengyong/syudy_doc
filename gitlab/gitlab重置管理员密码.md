1. 切换到`git`账户

   ```
   su - git
   ```

2. 进入`gitlab-rails`控制台：

   ```
   gitlab-rails console production
   ```

3. 查询超级管理员信息：

   ```
   user = User.where(id:1).first					[查询id=1的用户，一般为管理员账号]
   ```

   > 也可以通过`username`查询用户：` user = User.where(username:"root").first`

4. 重置密码并保存：

   ```
   user.password="12345678"				[密码最少8位]
   user.save!
   ```

5. 结束！



##### 附：为普通用户添加管理员权限（总有**禁用了standard登录方式后不留其他的管理员账号）

```
# 设置test账号为管理员账号
user = User.where(username:"test").first
user.admin="t"
user.save!
```

