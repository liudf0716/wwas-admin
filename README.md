# wwas-admin介绍
WWAS(wireless wifidog auth server) 是一个支持[apfree-wifidog](https://github.com/liudf0716/apfree-wifidog)的认证服务平台

wwas-admin是WWAS的管理配置前端，其主要功能包括：

> 用户管理（增加、冻结）

> 用户管理设备导入导出

> 用户管理设备列表

> 用户管理设备详情

> 认证用户列表详情

> 微信认证配置

> 短信认证配置（目前支持阿里，网易）

# 项目运行

```
git clone https://github.com/wificoin-project/wwas-admin.git

cd wwas-admin

npm install

npm run dev

```

# 另外

该项目的运行需要[WWAS](https://github.com/wificoin-project/wificoin-wifidog-auth-server)的后台支持，如需要了解[WWAS](https://github.com/wificoin-project/wificoin-wifidog-auth-server)的使用，请移步到：https://github.com/wificoin-project/wificoin-wifidog-auth-server

使用方法如下：

1.git clone https://github.com/wificoin-project/wwas-admin.git

2.cd wwas-admin

3.npm install

4.npm run build

5.把生成的dist文件夹整个复制到WWAS的public目录下即可。


如果只做前端开发，请忽略这段话。

# 说明

>  如果对您有帮助，您可以点右上角 "Star" 支持一下 谢谢！ ^_^

>  如有问题请直接在 [Issues](https://github.com/wificoin-project/wwas-admin/issues/new) 中提，或者您发现问题并有非常好的解决方案，欢迎 PR 👍

>  项目交流群：331230369(QQ) 424031785(QQ)


# 部分截图

### 登录

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/login.png"/>

### 渠道管理

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/qudao.png"/>

### 设备管理

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/device.png"/>

### 微信认证配置

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/weixin_auth.png"/>

### 短信认证配置

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/sms-auth.png"/>

### 其他认证配置

<img src="https://github.com/wificoin-project/wwas-admin/blob/master/other_auth.png"/>


