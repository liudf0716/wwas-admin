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
                                <el-input v-model="form0.secretKey" class="diainp2"></el-input>
                            </el-form-item>
                            <el-form-item label="SHOP_ID" prop="shopId">
                                <el-input v-model="form0.shopId" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="无线名称" prop="ssid">
                                <el-input v-model="form0.ssid" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="跳转" prop="portalUrl">
                                <el-input v-model="form0.portalUrl" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="时间" prop="duration">
                                <el-input v-model="form0.duration" class="diainp"></el-input>
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
                                <el-input v-model="form1.toAddress" class="diainp2"></el-input>
                            </el-form-item>
                            <el-form-item label="金额(WFC)" prop="toAmount">
                                <el-input v-model="form1.toAmount" class="diainp2"></el-input>
                            </el-form-item>
                            <el-form-item label="跳转" prop="portalUrl">
                                <el-input v-model="form1.portalUrl" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="时间" prop="duration">
                                <el-input v-model="form1.duration" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onWificoinSubmit('form1')">保存</el-button>
                            </el-form-item>
                        </el-form>
                    </div>

                </el-tab-pane>
                <!--<el-tab-pane label="其他设置" name="3">-->

                    <!--<div class="form-box tab-cont form-box2">-->
                        <!--<el-form ref="form2" :model="form2" :rules="rules1" label-width="150px">-->
                            <!--<el-form-item label="跳转页面" prop="portalUrl">-->
                                <!--<el-input v-model="form2.portalUrl" class="diainp2"></el-input>-->
                            <!--</el-form-item>-->
                            <!--<el-form-item label="duration" prop="">-->
                                <!--<el-input v-model="form2.duration" class="diainp"></el-input>-->
                            <!--</el-form-item>-->
                            <!--<el-form-item>-->
                                <!--<el-button type="primary" @click="onLastSubmit('form2')">保存</el-button>-->
                            <!--</el-form-item>-->
                        <!--</el-form>-->
                    <!--</div>-->

                <!--</el-tab-pane>-->
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
                task_type:'1',
                form0: {
                    gwId: '',

                    appId: 'wxfb684aa755dffceb',
                    app_secret: '',
                    shopId:'641418',
                    ssid:'ApFreeWiFiDog',
                    secretKey: 'ca0ddbac646160edfeaf343937f73404',

                    portalUrl:'https://talkblock.org/',
                    duration:'3600'
                },
                rules0: {
                    appId: [
                        {required: true, message: '请输入APP_ID', trigger: 'blur'},
                    ],
                    secretKey: [
                        {required: true, message: '请选择secretKey', trigger: 'blur'}
                    ],
                    shopId: [
                        {required: true, message: '请选择SHOP_ID', trigger: 'blur'}
                    ],
                    ssid: [
                        {required: true, message: '请输入无线名称', trigger: 'blur'}
                    ],
                    portalUrl: [
                        {required: true, message: '请选择跳转页面', trigger: 'blur'}
                    ],
                    duration: [
                        {required: true, message: '请输入时长', trigger: 'blur'}
                    ]

                },
                form1: {
                    channelPath: '',
                    toAddress:'wZirordpuoJgmRp6wRPKZjAjVruQr5gF7r',
                    toAmount:'2000000',

                    portalUrl:'https://talkblock.org/',
                    duration:'3600'
                },
                rules1: {
                    toAddress:[
                        { required: true, message: '请选择toAddress', trigger: 'blur'}
                    ],
                    toAmount: [
                        {required: true, message: '请输入toAmount', trigger: 'blur'},
                    ],
                    portalUrl: [
                        {required: true, message: '请选择跳转页面', trigger: 'blur'}
                    ],
                    duration: [
                        {required: true, message: '请输入时长', trigger: 'blur'}
                    ]
                },
                form2:{
                    portalUrl: '',
                    duration:''
                },
                rules2: {
                    portalUrl: [
                        {required: true, message: '请输入portalUrl', trigger: 'blur'},
                    ]
                },

                loading:false
            }
        },
        created:function () {
            // this.getGwid();
        },
        methods: {
            onWeixinSubmit:function (formName) {
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        var params = {
                            user_account:localStorage.getItem('ms_username'),
                            weixin:{
                                appId:self.form0.appId,
                                shopId:self.form0.shopId,
                                secretKey:self.form0.secretKey,
                                ssid:self.form0.ssid,
                            },
                            portalUrl: self.form0.portalUrl,
                            duration: self.form0.duration
                        };
                        self.loading = true;
                        self.$axios.post(global_.baseUrl + '/setting/weiXinSetting',params).then(function (res) {
                            // console.log(res.data);
                            self.loading = false;
                            if(res.data.ret_code == '1001'){
                                self.$message({message:res.data.extra,type:'warning'});
                                setTimeout(function(){
                                    self.$router.replace('login');
                                },2000)
                            }
                            if(res.data.ret_code == 0){
                                self.$message({message:res.data.extra,type:'success'});
                                self.task_type = '2';
                            }else{
                                self.$message.error(res.data.extra);
                            }
                        })

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
                        var params = {
                            user_account:localStorage.getItem('ms_username'),
                            wificoin: {
                                toAddress:self.form1.toAddress,
                                toAmount:self.form1.toAmount
                            },
                            portalUrl:self.form1.portalUrl,
                            duration:self.form1.duration
                        };
                        self.loading = true;
                        self.$axios.post(global_.baseUrl + '/setting/wfcSetting',params).then(function (res) {
                            self.loading = false;
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

            },
            onLastSubmit: function(formName){
                var self = this;
                self.$refs[formName].validate(function (valid) {
                    if (valid) {
                        self.params.portalUrl = self.form1.portalUrl;
                        self.params.duration = self.form1.duration;
                        self.loading = true;
                        self.$axios.post(global_.baseUrl + '/url',params).then(function (res) {
                            self.loading = false;
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
                            self.form2.route_mac = '';
                            self.form2.script_name = '';
                            self.form2.script_mode = '1';
                            self.form2.upgrade_time = '';
                            self.form2.expired_time = '0';
                            self.form2.isTime = true;
                            self.form2.operator = '';

                        })

                    } else {
                        return false;
                        console.log('验证失败');
                    }
                });
            },
            getGwid: function(){//获取数据
                var self = this;
                self.$axios.post(global_.baseUrl+'/url').then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        var gwidData = res.data.extra;
                        self.form0.appId = gwidData.appId;
                    }
                })
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
            validateTimeNum: function (rule, value, callback) {
                var self = this;
                var reg = /^\d+$/;
                if(!reg.test(value)){
                    callback(new  Error('输入必须是数字'));
                }
                // if(!self.form0.isTime || !self.form1.isTime){
                if((self.task_type == '1' && self.isValidTime0) || (self.task_type == '2' && self.isValidTime1) || (self.task_type == '3' && self.isValidTime2)){
                    if(!reg.test(value) || Number(value)<24){
                        callback(new Error('输入必须是数字,且不小于24'));
                    }else{
                        callback();
                    }
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
        }
    }
</script>
<style>
    .mb40 {margin-bottom: 40px;}
    .tab-cont {padding: 40px; /*border-top:1px solid #dfe6ec;*/}
    .diainp{width:217px;}
    .diainp2{width:450px;}
    .inp100{width:100px;}
    /*.textarea-mac{height:160px;}*/
    .form-box2{width:700px;}
    .txt{width:700px;padding-left:40px;font-size:15px;color:#666;margin-bottom:30px;}
    .txt p{line-height:36px;}
    .txt .txt-small span{display:block;margin-left:20px;font-size:14px;line-height:26px;}
</style>
