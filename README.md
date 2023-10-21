# wwas-admin介绍
wwas是一个支持[apfree-wifidog](https://github.com/liudf0716/apfree-wifidog)的认证服务平台

wwas-admin是WWAS的管理配置前端，其主要功能包括：

> 用户管理（增加、冻结）

> 用户管理设备导入导出

> 用户管理设备列表

> 用户管理设备详情

> 认证用户列表详情

> 微信认证配置

> 短信认证配置（目前支持阿里，网易）

> 一键免认证配置

# 项目运行

```
git clone https://github.com/liudf0716/wwas-admin.git

cd wwas-admin

npm install

npm run dev

```

# 另外

该项目的运行需要[wwas](https://github.com/liudf0716/wwas)的后台支持

使用方法如下：

1.git clone https://github.com/liudf0716/wwas-admin.git

2.cd wwas-admin

3. 修改config/index.js文件

```
 webServer: 'http://yourip:8001'
```

4.npm install

5.npm run build

6.把生成的dist文件夹整个复制到wwas的public目录下即可。

```
cp -r dist/* ../wwas/public/
```


如果只做前端开发，请忽略这段话。

# 说明

>  如果对您有帮助，您可以点右上角 "Star" 支持一下 谢谢！ ^_^

>  如有问题请直接在 [Issues](https://github.com/liudf0716/wwas-admin/issues/new) 中提，或者您发现问题并有非常好的解决方案，欢迎 PR 👍

>  项目交流群：331230369(QQ) 424031785(QQ)


# 部分截图

### 登录

<img src="https://github.com/liudf0716/wwas-admin/blob/master/login.png"/>

### 渠道管理

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/43f2cc31-481b-4ee6-a1f9-26702aec7b2f)


### 设备管理

<img src="https://github.com/liudf0716/wwas-admin/blob/master/device.png"/>


### 微信认证配置

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/5270faa1-03d6-47f9-9fba-8acaf169e3a1)


### 短信认证配置

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/ecf7c160-9b48-4425-aa9f-48726575a283)

### 一键免认证配置

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/b6542bc9-ae79-4a2c-897f-1a34df71549c)

### 用户密码认证配置

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/2653fc32-04a2-4e84-a68f-4ce7026ff503)


### 其他认证配置

![image](https://github.com/liudf0716/wwas-admin/assets/1182593/c705997a-7064-4102-8c84-d882e397177d)



