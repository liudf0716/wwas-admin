<template>
    <div v-loading="loading">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-document"></i> 认证管理</el-breadcrumb-item>
                <el-breadcrumb-item>设置</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class='rad-group mb40'>
            <el-tabs v-model="task_type" type="card" @tab-click="handleClick">
                <el-tab-pane label="微信认证" name="1">
                    <div class="txt" style="font-size:16px;color:#666;">
                        <p>APP_ID：请从微信公众平台左侧最下方“开发－基本设置”获取。</p>
                        <!--<p>APP_SECRET：请从微信公众平台左侧最下方“开发－基本设置”获取。</p>-->
                        <p>SHOP_ID及对应SSID和secretKey：</p>
                        <p class="txt-small">
                            <span>1 进入微信公众平台左侧“微信连Wi-Fi”中的“设备管理”。</span>
                            <span>2 点击相应门店右侧的“查看详情”进入设备详情页面。</span>
                            <span>3 点击中部“查看设备改造信息”按钮，在弹出框中获取。</span>
                        </p>
                    </div>
                    <div class="form-box tab-cont form-box2">
                        <el-form :model="form_wx" :rules="rules_wx" ref="form_wx" label-width="150px">
                            <el-form-item label="APP_ID" prop="appId">
                                <el-input v-model="form_wx.appId" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="secretKey" prop="secretKey">
                                <el-input v-model="form_wx.secretKey" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="SHOP_ID" prop="shopId">
                                <el-input v-model="form_wx.shopId" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form_wx.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onWeixinSubmit('form_wx')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane>

                <el-tab-pane label="一键免认证" name="2">
                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form_onekey" :model="form_onekey"  label-width="150px">
                            <el-form-item label="启用">
                                <el-switch v-model="form_onekey.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onOnekeySubmit('form_onekey')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                </el-tab-pane>

                <el-tab-pane label="用户密码认证" name="3">
                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form_user" :model="form_user" :rules="rules_user" label-width="150px">
                            <el-form-item label="用户名" prop="username">
                                <el-input v-model="form_user.username" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="用户密码" prop="password">
                                <el-input v-model="form_user.password" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form_user.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onPasswordSubmit('form_user')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane> 
                
                <el-tab-pane label="短信认证" name="4">

                    <el-form class="form-box tab-cont form-box2">
                        <el-form ref="form_dx" :model="form_dx" label-width="150px">
                            <el-form-item label="短信服务商" prop="dxchoose">
                                <el-select v-model="dxchoose" placeholder="请选择短信服务商" @change="changeDxchoose">
                                    <el-option label="阿里云" value="ali"></el-option>
                                    <el-option label="网易云信" value="wy"></el-option>
                                    <el-option label="无短信认证" value="none"></el-option>
                                </el-select>
                            </el-form-item>
                            <el-form ref="formAli" :model="formAli" :rules="rulesAli" label-width="150px" v-show="dxchoose == 'ali'">
                                <el-form-item label="AccessKeyId" prop="appId">
                                    <el-input v-model="formAli.appId" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="AccessKeySecret" prop="appSecret">
                                    <el-input v-model="formAli.appSecret" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="SignName" prop="smsSignName">
                                    <el-input v-model="formAli.smsSignName" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="TemplateCode" prop="smsTemplateCode">
                                    <el-input v-model="formAli.smsTemplateCode" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="启用">
                                    <el-switch v-model="formAli.enable" class="diainp"></el-switch>
                                </el-form-item>
                                <el-form-item>
                                    <el-button type="primary" @click="onDuanxinSubmit('formAli')">下一步</el-button>
                                </el-form-item>
                            </el-form>
                            <el-form ref="formWy" :model="formWy" :rules="rulesWy" label-width="150px" v-show="dxchoose == 'wy'">
                                <el-form-item label="AppKey" prop="wyAppId">
                                    <el-input v-model="formWy.wyAppId" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="AppSecret" prop="wyAppSecret">
                                    <el-input v-model="formWy.wyAppSecret" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="TemplateId" prop="wyTemplateId">
                                    <el-input v-model="formWy.wyTemplateId" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="启用">
                                    <el-switch v-model="formWy.enable" class="diainp"></el-switch>
                                </el-form-item>
                                <el-form-item>
                                    <el-button type="primary" @click="onDuanxinSubmit('formWy')">下一步</el-button>
                                </el-form-item>
                            </el-form>
                            <el-form ref="formNone" :model="formNone" label-width="150px" v-show="dxchoose == 'none'">
                                <el-form-item>
                                    <el-button type="primary" @click="onDuanxinSubmit('formNone')">下一步</el-button>
                                </el-form-item>
                            </el-form>

                        </el-form>
                    </el-form>

                </el-tab-pane>
                <el-tab-pane label="其他设置" name="5">

                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form_other" :model="form_other" :rules="rules_other" label-width="150px">

                            <el-form-item label="跳转" prop="portalUrl">
                                <el-input v-model="form_other.portalUrl" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="时间" prop="duration">
                                <el-select v-model="form_other.duration" class="diainp" placeholder="请选择" @change="changeDuration">
                                    <el-option
                                        v-for="item in durations"
                                        :key="item"
                                        :label="item"
                                        :value="item">
                                    </el-option>
                                </el-select>
                                <span style="padding:5px 12px;">小时</span>
                            </el-form-item>
                            <el-form-item label="单手机号能同时认证的设备数" prop="multiDevOL">
                                <el-select v-model="form_other.multiDevOL" class="diainp" placeholder="请选择" @change="changeMultiDevOL">
                                    <el-option
                                        v-for="item in multiDevOLs"
                                        :key="item"
                                        :label="item"
                                        :value="item">
                                    </el-option>
                                </el-select>
                                <span style="padding:5px 12px;">台</span>
                            </el-form-item>
                            <el-form-item label="客户超时认证时间" prop="clientTimeout">
                                <el-select v-model="form_other.clientTimeout" class="diainp" placeholder="请选择" @change="changeClientTimeout">
                                    <el-option
                                        v-for="item in clientTimeoutOp"
                                        :key="item"
                                        :label="item"
                                        :value="item">
                                    </el-option>
                                </el-select>
                                <span style="padding:5px 12px;">分钟</span>
                            </el-form-item>
                            <el-form-item label="背景图片" prop="backgroundUrl">
                                <el-upload
                                    class="upload-demo"
                                    :action="actionUrl"
                                    ref="upload"
                                    name="file_name"
                                    with-credentials="true"
                                    list-type="picture"
                                    :data="backgroundUrl"
                                    :beforeUpload="beforeUpload"
                                    :on-change="handleChange"
                                    :on-success="handleSuccess"
                                    :file-list="fileList"
                                    :auto-upload="true">
                                    <el-button slot="trigger" size="small" type="primary">选取图片</el-button>
                                    <div slot="tip" class="el-upload__tip">只能上传jpg/png文件,且不超过1M</div>
                                </el-upload>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onLastSubmit('form_other')">保存</el-button>
                            </el-form-item>
                        </el-form>
                    </div>

                </el-tab-pane>

            </el-tabs>
        </div>

    </div>
</template>

<script>
    import global_ from 'components/common/Global';
    export default {
        data: function () {
            return {
                params:{},
                active:0,
                task_type:'1',
                form_wx: {
                    appId: '',
                    app_secret: '',
                    shopId:'',
                    ssid:'',
                    secretKey: '',
                    enable: false,
                },
                durations:[1,2,3,4,5,6,7,8,9,10,11,12],
                multiDevOLs:[1,2,3,4,5,6],
                clientTimeoutOp:[2,4,6,8,10,20,30,60,120,360],
                rules_wx: {
                    appId: [
                        {required: true, message: '请输入APP_ID', trigger: 'blur'},
                    ],
                    secretKey: [
                        {required: true, message: '请输入secretKey', trigger: 'blur'}
                    ],
                    shopId: [
                        {required: true, message: '请输入SHOP_ID', trigger: 'blur'}
                    ]

                },
                form_onekey: {
                    enable: true,
                },
                form_user: {
                  username:'',
                  password:'',
                  enable: true,
                },
                rules_user: {
                  username:[
                    { required: true, message: '请输入用户名', trigger: 'blur'}
                  ],
                  password:[
                    { required: true, message: '请输入用户名密码', trigger: 'blur'}
                  ]
                },
                form_other: {
                    portalUrl:'',
                    duration:'',
                    multiDevOL:'',
                    clientTimeout:'',
                },
                rules_other: {
                    portalUrl: [
                        {required: true, message: '请输入跳转页面', trigger: 'blur'},
                        {validator: this.validateUrl, trigger: 'blur'}
                    ],
                    duration: [
                        {required: true, message: '请选择时长', trigger: 'change'}
                    ],
                    multiDevOL: [
                        {required: true, message: '请选择能一个电话号能同时认证路由器的台数', trigger: 'change'}
                    ],
                    clientTimeout: [
                        {required: true, message: '选择客户超时认证时间', trigger: 'change'}
                    ],
                },
                form_dx:{

                },
                formAli:{
                    appId:'',
                    appSecret:'',
                    smsSignName:'',
                    smsTemplateCode:'',
                    enable:true,
                },
                rulesAli: {
                    appId: [
                        {required: true, message: '请输入AccessKeyId', trigger: 'blur'},
                    ],
                    appSecret: [
                        {required: true, message: '请输入AccessKeySecret', trigger: 'blur'}
                    ],
                    smsSignName: [
                        {required: true, message: '请输入SignName', trigger: 'blur'}
                    ],
                    smsTemplateCode:[
                        {required: true, message: '请输入TemplateCode', trigger: 'blur'}
                    ]

                },
                formWy:{
                    wyAppId:'',
                    wyAppSecret:'',
                    wyTemplateId:'',
                    enable: true,
                },
                rulesWy: {
                    wyAppId: [
                        {required: true, message: '请输入AppKey', trigger: 'blur'},
                    ],
                    wyAppSecret: [
                        {required: true, message: '请输入AppSecret', trigger: 'blur'}
                    ],
                    wyTemplateId: [
                        {required: true, message: '请输入TemplateId', trigger: 'blur'}
                    ]

                },
                formNone:{
                    enable:false,
                },
                dxchoose:'none',
                actionUrl: global_.baseUrl + '/setting/uploadBgImage',
                fileList: [],
                loading:false
            }
        },
        created:function () {
            this.getData();
        },
        methods: {
            prev: function(){
                this.active--;
            },
            onWeixinSubmit:function (formName) {
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        self.params = {
                            user_account:localStorage.getItem('ms_username'),
                            weixin:{
                                appId:self.form_wx.appId,
                                shopId:self.form_wx.shopId,
                                secretKey:self.form_wx.secretKey,
                                enable:self.form_wx.enable,
                            }
                        };
                        self.active = 1;
                        self.task_type = '2';
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                });

            },
            onOnekeySubmit:function (formName) {
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        self.params.onekey = {
                            enable:self.form_onekey.enable,
                        };
                        self.active = 2;
                        self.task_type = '3';
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                });

            },
            onPasswordSubmit: function(formName) {
              var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        self.params.user = {
                            user:self.form_user.usernmae,
                            password:self.form_user.password,
                            enable:self.form_user.enable,
                        };
                        self.active = 3;
                        self.task_type = '4';
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                });

            },
            onDuanxinSubmit: function(formName) {
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        if(formName == 'formAli'){
                            self.params.sms = {
                                selected:self.dxchoose,
                                appId:self.formAli.appId,
                                appSecret:self.formAli.appSecret,
                                smsSignName:self.formAli.smsSignName,
                                smsTemplateCode:self.formAli.smsTemplateCode,
                                enable:self.formAli.enable,
                            };
                        }else if(formName == 'formWy'){
                            self.params.sms = {
                                selected:self.dxchoose,
                                wyAppId:self.formWy.wyAppId,
                                wyAppSecret:self.formWy.wyAppSecret,
                                wyTemplateId:self.formWy.wyTemplateId,
                                enable:self.formWy.enable,
                            };
                        } else {
                            self.params.sms = {
                                selected:'none',
                                enable:false,
                            };
                        }

                        self.active = 4;
                        self.task_type = '5';
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                });

            },
            onLastSubmit: function(formName){
                var self = this;
                self.$refs['form_wx'].validate(function (valid) {
                    if(valid){
                        self.$refs[formName].validate(function (valid) {
                            if (valid) {
                                self.params.user_account = localStorage.getItem('ms_username');
                                self.params.weixin = {
                                    appId:self.form_wx.appId,
                                    shopId:self.form_wx.shopId,
                                    secretKey:self.form_wx.secretKey,
                                    enable:self.form_wx.enable,
                                };

                                self.params.onekey = {
                                    enable:self.form_onekey.enable,
                                };

                                self.params.user = {
                                    user:self.form_user.username,
                                    password:self.form_user.password,
                                    enable:self.form_user.enable,
                                };

                                self.params.portalUrl = self.form_other.portalUrl;
                                self.params.duration = self.form_other.duration;
                                self.params.multiDevOL = self.form_other.multiDevOL;
                                self.params.clientTimeout = self.form_other.clientTimeout;
                                if (self.fileList.length > 0) {
                                    self.params.backgroundUrl = self.fileList[0].response;
                                    self.fileList.pop();
                                } else {
                                    self.params.backgroundUrl = '/static/img/lg_pic.png';
                                }
                                
                                if(self.dxchoose == 'ali'){
                                    self.params.sms = {
                                        selected:self.dxchoose,
                                        appId:self.formAli.appId,
                                        appSecret:self.formAli.appSecret,
                                        smsSignName:self.formAli.smsSignName,
                                        smsTemplateCode:self.formAli.smsTemplateCode,
                                        enable:self.formAli.enable,
                                    }
                                } else if (self.dxchoose == 'wy'){
                                    self.params.sms = {
                                        selected:self.dxchoose,
                                        wyAppId:self.formWy.wyAppId,
                                        wyAppSecret:self.formWy.wyAppSecret,
                                        wyTemplateId:self.formWy.wyTemplateId,
                                        enable:self.formWy.enable,
                                    }
                                } else {
                                    self.params.sms = {
                                        selected:self.dxchoose,
                                        enable: self.formNone.enable,
                                    }
                                }

                                self.loading = true;
                                self.$axios.post(global_.baseUrl + '/setting/wfcSetting',self.params).then(function (res) {
                                    self.loading = false;
                                    self.active = 4;
                                    if(res.data.ret_code == '1001'){
                                        self.$message({message:res.data.extra,type:'warning'});
                                        setTimeout(function(){
                                            self.$router.replace('login');
                                        },2000)
                                    }
                                    if(res.data.ret_code == 0){
                                        self.$message({message:res.data.extra,type:'success'});

                                    }else{
                                        self.$message.error(res.data.extra)
                                    }
                                })
                            } else {
                                return false;
                                console.log('验证失败');
                            }
                        });
                    }else{
                        self.task_type = '1';
                        return false;
                    }
                });
            },
            getData: function(){//获取数据
                var self = this;
                var params = {
                    user_account:localStorage.getItem('ms_username')
                }
                self.$axios.post(global_.baseUrl+'/setting/getSetting',params).then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        var requestData = res.data.extra;
                        self.form_wx.appId = requestData.appId;
                        self.form_wx.shopId = requestData.shopId;
                        self.form_wx.secretKey = requestData.secretKey;
                        self.form_wx.ssid = requestData.ssid;
                        self.form_wx.enable = requestData.wxEnable;
                        
                        self.form_other.portalUrl = requestData.portalUrl;
                        self.form_other.duration = String(requestData.duration);
                        self.form_other.multiDevOL = requestData.multiDevOL;
                        self.form_other.clientTimeout = requestData.clientTimeout;
                        

                        self.form_user.username = requestData.user;
                        self.form_user.password = requestData.password;
                        self.form_user.enable = requestData.userEnable;

                        self.form_onekey.enable = requestData.onekeyEnable;
                        
                        self.formAli.appId = requestData.smsAppId;
                        self.formAli.appSecret = requestData.smsAppSecret;
                        self.formAli.smsSignName = requestData.smsSignName;
                        self.formAli.smsTemplateCode = requestData.smsTemplateCode;
                        self.formAli.enable = requestData.smsAliEnable;


                        self.formWy.wyAppId = requestData.smsWyAppId;
                        self.formWy.wyAppSecret = requestData.smsWyAppSecret;
                        self.formWy.wyTemplateId = requestData.smsWyTemplateId;
                        self.formWy.enable = requestData.smsWyEnable;


                        self.dxchoose = requestData.smsSelected;
                    }
                })
            },
            changeDxchoose: function(e){
                var self = this;
                self.dxchoose = e;

            },
            changeDuration: function(value){
                var self = this;
                self.form_other.duration = String(value);
            },
            changeMultiDevOL: function(value) {
                var self = this;
                self.form_other.multiDevOL = String(value);
            },
            changeClientTimeout: function(value) {
                var self = this;
                self.form_other.clientTimeout = String(value);
            },
            validateUrl: function (rule, value, callback) {
                var self = this;
                var reg = /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?/;
                if(!reg.test(value)){
                    callback(new  Error('请输入正确网址，如(http://baidu.com)'));
                }else{
                    callback();
                }

            },
            validateNum: function (rule, value, callback) {
                var self = this;
                var reg = /^\d+(\.\d+)?$/; //非负浮点数
                if(!reg.test(value)){
                    callback(new  Error('输入必须是数字'));
                }else{
                    callback();
                }

            },
            validateTimeNum: function (rule, value, callback) {
                var self = this;
                var reg = /^\d+$/;
                if(!reg.test(value)){
                    callback(new  Error('输入必须是数字'));
                }else{
                    callback();
                }

            },
            getChannelPath: function(){
                var self = this;
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/script/list').then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    self.loading = false;
                    if(res.data.ret_code == 0){
                        self.scriptListData = res.data.extra;
                    }else{
                        self.$message.error(res.data.extra)
                    }
                })
            },
            handleClick:function (tab,event) {
                var self = this;
                if(tab.name == '1'){
                    // self.getGwid();
                }
                if(tab.name == '2'){
                    // self.getChannelPath();
                }
            },

            validateSpace: function (rule, value, callback) {
                var self = this;
                if(value.indexOf(' ')>=0){
                    callback(new Error('输入有空格'));
                }else{
                    callback();
                }
            },
            validateMac: function (rule, value, callback) {
                var self = this;
                var reg_name = /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
                var reg_name2 = /^[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}$/;
                var macarr = self.splitStr(value);
                var len = macarr.length;
                for (var i = 0; i < len; i++) {
                    if (!reg_name.test(macarr[i]) && !reg_name2.test(macarr[i])) {
                        callback(new Error('输入有误，以逗号或回车分隔'));
                    } else {
                        callback();
                    }
                }
            },
            //按逗号和回车分隔字符串
            splitStr: function (str) {
                var temp = str.split(/[\n,]/g);
                for (var i = 0; i < temp.length; i++) {
                    if (temp[i] == "") {
                        temp.splice(i, 1);
                        //删除数组索引位置应保持不变
                        i--;
                    }
                }
                return temp;
            },
            beforeUpload: function(file){
                var testmsg=file.name.substring(file.name.lastIndexOf('.')+1);
                const extension = testmsg === 'png';
                const extension2 = testmsg === 'jpg';
                const isLt2M = file.size / 1024 / 1024 < 1;
                if (!extension && !extension2) {
                    this.$message({message:'上传图片只支持png或者jpg格式!',type:'warning'});
                    return false;
                }
                if (!isLt2M) {
                    this.$message({message:'上传图片大小不能超过 1MB!',type:'warning'});
                    return false;
                }
                
                return true;
            },
            handleSuccess: function(response, file, fileList) {
                if (response.ret_code == 0) {
                    file.response = response.extra;
                    this.fileList.push(file);
                } else {
                    this.$message.error(response.extra);
                }
            },
        }
    }
</script>
<style scoped>
    .last-cont{}
    .steps-tit{margin-bottom:30px;}
    .mb40 {margin-bottom: 40px;}
    .tab-cont {padding: 40px; /*border-top:1px solid #dfe6ec;*/}
    .diainp{width:260px;}
    .diainp2{width:260px;}
    .inp100{width:100px;}
    /*.textarea-mac{height:160px;}*/
    .form-box2{width:700px;}
    .txt{width:700px;padding-left:40px;font-size:15px;color:#666;margin-bottom:30px;}
    .txt p{line-height:36px;}
    .txt .txt-small span{display:block;margin-left:20px;font-size:14px;line-height:26px;}
</style>
