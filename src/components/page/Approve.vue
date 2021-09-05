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
                        <el-form :model="form0" :rules="rules0" ref="form0" label-width="150px">
                            <el-form-item label="APP_ID" prop="appId">
                                <el-input v-model="form0.appId" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="secretKey" prop="secretKey">
                                <el-input v-model="form0.secretKey" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="SHOP_ID" prop="shopId">
                                <el-input v-model="form0.shopId" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form0.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onWeixinSubmit('form0')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane>
                <el-tab-pane label="WFC认证" name="2">

                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form1" :model="form1" :rules="rules1" label-width="150px">
                            <el-form-item label="钱包地址" prop="toAddress">
                                <el-input v-model="form1.toAddress" class="diainp"></el-input>
                                <a href="https://wfc.wificoin.club/" target="_blank" style="padding:5px 12px;color:#20a0ff;">查看地址</a>
                            </el-form-item>
                            <el-form-item label="金额(WFC)" prop="toAmount">
                                <el-input v-model="form1.toAmount" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form1.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onWificoinSubmit('form1')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                    </div>

                </el-tab-pane>
                
                <el-tab-pane label="用户密码认证" name="3">

                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form4" :model="form4" :rules="rules4" label-width="150px">
                            <el-form-item label="用户名" prop="username">
                                <el-input v-model="form4.username" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="用户密码" prop="password">
                                <el-input v-model="form4.password" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form4.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onPasswordSubmit('form4')">下一步</el-button>
                            </el-form-item>
                        </el-form>
                    </div>

                </el-tab-pane>
                
                <el-tab-pane label="短信认证" name="4">

                    <el-form class="form-box tab-cont form-box2">
                        <el-form ref="form3" :model="form3" label-width="150px">
                            <el-form-item label="短信服务商" prop="dxchoose">
                                <el-select v-model="dxchoose" placeholder="请选择短信服务商" @change="changeDxchoose">
                                    <el-option label="阿里云" value="ali"></el-option>
                                    <el-option label="网易云信" value="wy"></el-option>
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


                        </el-form>
                    </el-form>

                </el-tab-pane>
                <el-tab-pane label="其他设置" name="5">

                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form2" :model="form2" :rules="rules2" label-width="150px">

                            <el-form-item label="跳转" prop="portalUrl">
                                <el-input v-model="form2.portalUrl" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="时间" prop="duration">
                                <!--<el-input v-model="form0.duration" class="diainp"></el-input>-->
                                <el-select v-model="form2.duration" class="diainp" placeholder="请选择" @change="changeDuration">
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
                                <el-select v-model="form2.multiDevOL" class="diainp" placeholder="请选择" @change="changeMultiDevOL">
                                    <el-option
                                        v-for="item in mutiDevOLs"
                                        :key="item"
                                        :label="item"
                                        :value="item">
                                    </el-option>
                                </el-select>
                                <span style="padding:5px 12px;">台</span>
                            </el-form-item>
                            <el-form-item label="客户超时认证时间" prop="clientTimeout">
                                <el-select v-model="form2.clientTimeout" class="diainp" placeholder="请选择" @change="changeClientTimeout">
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
                                    <div slot="tip" class="el-upload__tip">只能上传jpg/png文件，且不超过1M</div>
                                </el-upload>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onLastSubmit('form2')">保存</el-button>
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
    var crypto = require('crypto');
    export default {
        data: function () {
            return {
                params:{},
                active:0,
                task_type:'1',
                form0: {
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
                rules0: {
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
                form1: {
                    toAddress:'',
                    toAmount:'',
                    enable: false,
                },
                rules1: {
                    toAddress:[
                        { required: true, message: '请输入钱包地址', trigger: 'blur'}
                    ],
                    toAmount: [
                        {required: true, message: '请输入金额', trigger: 'blur'},
                        {validator: this.validateNum, trigger: 'blur'}
                    ]
                },
                form4: {
                  username:'',
                  password:'',
                  enable: true,
                },
                rules4: {
                  username:[
                    { required: true, message: '请输入用户名', trigger: 'blur'}
                  ],
                  password:[
                    { required: true, message: '请输入用户名密码', trigger: 'blur'}
                  ]
                },
                form2: {
                    portalUrl:'',
                    duration:'',
                    multiDevOL:'',
                    clientTimeout:'',
                },
                rules2: {
                    portalUrl: [
                        {required: true, message: '请输入跳转页面', trigger: 'blur'},
                        {validator: this.validateUrl, trigger: 'blur'}
                    ],
                    duration: [
                        {required: true, message: '请选择时长', trigger: 'change'}
                    ],
                    multiDevOL: [
                        {required: true, message: '请选择台数', trigger: 'change'}
                    ],
                },
                form3:{

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
                dxchoose:'ali',
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
                                appId:self.form0.appId,
                                shopId:self.form0.shopId,
                                secretKey:self.form0.secretKey,
                                enable:self.form0.enable,
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
            onWificoinSubmit: function(formName) {
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        self.params.wificoin = {
                            toAddress:self.form1.toAddress,
                            toAmount:self.form1.toAmount,
                            enable:self.form1.enable,
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
                            user:self.form4.usernmae,
                            password:self.form4.password,
                            enable:self.form4.enable,
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
                        }else{
                            self.params.sms = {
                                selected:self.dxchoose,
                                wyAppId:self.formWy.wyAppId,
                                wyAppSecret:self.formWy.wyAppSecret,
                                wyTemplateId:self.formWy.wyTemplateId,
                                enable:self.formWy.enable,
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
                self.$refs['form0'].validate(function (valid) {
                    if(valid){

                        self.$refs['form1'].validate(function (valid) {
                            if(valid){

                                self.$refs[formName].validate(function (valid) {
                                    if (valid) {
                                        self.params.user_account = localStorage.getItem('ms_username');
                                        self.params.weixin = {
                                            appId:self.form0.appId,
                                            shopId:self.form0.shopId,
                                            secretKey:self.form0.secretKey,
                                            // ssid:self.form0.ssid,
                                            enable:self.form0.enable,
                                        };
                                        self.params.wificoin = {
                                            toAddress:self.form1.toAddress,
                                            toAmount:self.form1.toAmount,
                                            enable:self.form1.enable,
                                        };
					
					                    self.params.user = {
						                    user:self.form4.username,
						                    password:self.form4.password,
                                            enable:self.form4.enable,
					                    };

                                        self.params.portalUrl = self.form2.portalUrl;
                                        self.params.duration = self.form2.duration;
                                        self.param.multiDevOL = self.form2.multiDevOL;
                                        self.param.clientTimeout = self.form2.clientTimeout;
                                        if (self.fileList.length > 0)
                                            self.params.backgroundUrl = self.fileList[0].response;
                                        self.fileList.pop();
                                        
                                        if(self.dxchoose == 'ali'){
                                            self.params.sms = {
                                                selected:self.dxchoose,
                                                appId:self.formAli.appId,
                                                appSecret:self.formAli.appSecret,
                                                smsSignName:self.formAli.smsSignName,
                                                smsTemplateCode:self.formAli.smsTemplateCode,
                                                enable:self.formAli.enable,
                                            }
                                        }else{
                                            self.params.sms = {
                                                selected:self.dxchoose,
                                                wyAppId:self.formWy.wyAppId,
                                                wyAppSecret:self.formWy.wyAppSecret,
                                                wyTemplateId:self.formWy.wyTemplateId,
                                                enable:self.formWy.enable,
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
                                self.task_type = '2';
                                return false;
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
                        self.form0.appId = requestData.appId;
                        self.form0.shopId = requestData.shopId;
                        self.form0.secretKey = requestData.secretKey;
                        self.form0.ssid = requestData.ssid;
                        self.form0.enable = requestData.wxEnable;
                        self.form2.portalUrl = requestData.portalUrl;
                        self.form2.duration = String(requestData.duration);
                        self.form2.multiDevOL = requestData.multiDevOL;
                        self.form2.clientTimeout = requestData.clientTimeout;
                        
                        self.form1.toAddress = requestData.toAddress;
                        self.form1.toAmount = String(requestData.toAmount);
                        self.form1.enable = requestData.wfcEnable;

                        self.form4.username = requestData.user;
                        self.form4.password = requestData.password;
                        self.form4.enable = requestData.userEnable;
                        
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
                self.form2.duration = String(value);
            },
            changeMultiDevOL: function(value) {
                var self = this;
                self.form2.multiDevOL = String(value);
            },
            changeClientTimeout: function(value) {
                var self = this;
                self.form2.clientTimeout = String(value);
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
