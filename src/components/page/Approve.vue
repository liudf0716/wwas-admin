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
                <el-tab-pane label="微信支付上网" name="wxpay_setting">
                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form_wxpay" :model="form_wxpay" :rules="rules_wxpay" label-width="150px">
                            <el-form-item label="商户号" prop="mch_id">
                                <el-input v-model="form_wxpay.mch_id" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="商户证书序列号" prop="mch_serial_no">
                                <el-input v-model="form_wxpay.mch_serial_no" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="商户APIv3密钥" prop="mch_v3_key">
                                <el-input v-model="form_wxpay.mch_v3_key" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="商户API私钥文件" prop="mch_priv_key">
                                <el-upload
                                    class="upload-demo"
                                    :action="uploadKey"
                                    ref="upload"
                                    name="file_name"
                                    with-credentials="true"
                                    list-type="text"
                                    :data="mch_priv_key"
                                    :beforeUpload="beforeWxpayUpload"
                                    :on-success="uploadSuccess"
                                    :file-list="mch_priv_key_filelist"
                                    :auto-upload="true"
                                    :limit="1">
                                    <el-button slot="trigger" size="small" type="primary">选取商户私钥</el-button>
                                    <div slot="tip" class="el-upload__tip">上传商户私钥文件,大小不能超过128K</div>
                                </el-upload>
                            </el-form-item>   
                            <el-form-item label="微信支付平台证书" prop="wx_cert">
                                <el-upload
                                    class="upload-demo"
                                    :action="uploadCert"
                                    ref="upload"
                                    name="file_name"
                                    with-credentials="true"
                                    list-type="text"
                                    :data="mch_cert"
                                    :beforeUpload="beforeWxpayUpload"
                                    :on-success="uploadSuccess"
                                    :file-list="wx_cert_filelist"
                                    :auto-upload="true"
                                    :limit="1"
                                    accept=".crt,.pem,.cer">
                                    <el-button slot="trigger" size="small" type="primary">选取微信支付平台证书</el-button>
                                    <div slot="tip" class="el-upload__tip">上传微信支付平台证书文件, 大小不能超过128K</div>
                                </el-upload>
                            </el-form-item>
                            <el-form-item label="AppID" prop="app_id">
                                <el-input v-model="form_wxpay.app_id" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="支付金额" prop="amount">
                                <el-input v-model="form_wxpay.amount" class="diainp"></el-input>
                                <span style="padding:5px 12px;">元</span>
                            </el-form-item>
                            <el-form-item label="支付完成通知域名" prop="notify_domain">
                                <el-input v-model="form_wxpay.notify_domain" class="diainp" @input="updateNotifyUrl"></el-input>
                                <div class="text">
                                    <p>
                                        支付完成通知域名是微信支付完成后的回调地址<br>
                                        用于接收微信支付结果通知。<br>
                                        支付通知url为: <code>{{ form_wxpay.notify_url }}</code>
                                    </p>
                                </div>
                            </el-form-item>
                            <el-form-item label="描述" prop="desc">
                                <el-input v-model="form_wxpay.desc" class="diainp"></el-input>
                            </el-form-item>
                            <el-form-item label="启用">
                                <el-switch v-model="form_wxpay.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="onSaveSubmit('form_wxpay')">保存配置</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane>

                <el-tab-pane label="一键免认证" name="onekey_setting">
                    <div class="form-box tab-cont form-box2">
                        <el-form ref="form_onekey" :model="form_onekey" label-width="150px">
                            <el-form-item label="启用">
                                <el-switch v-model="form_onekey.enable" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item label="服务端放行">
                                <el-switch v-model="form_onekey.from_server" class="diainp"></el-switch>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary"  @click="onSaveSubmit('form_onekey')">保存配置</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane>

                <el-tab-pane label="用户密码认证" name="user_setting">
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
                                <el-button type="primary"  @click="onSaveSubmit('form_user')">保存配置</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-tab-pane> 
                
                <el-tab-pane label="短信认证" name="sms_setting">
                    <el-form class="form-box tab-cont form-box2">
                        <el-form ref="form_dx" :model="form_dx" label-width="150px">
                            <el-form-item label="短信服务商" prop="dxchoose">
                                <el-select v-model="dxchoose" placeholder="请选择短信服务商" @change="changeDxchoose">
                                    <el-option label="阿里云" value="ali"></el-option>
                                    <el-option label="网易云信" value="wy"></el-option>
                                    <el-option label="无短信认证" value="none"></el-option>
                                </el-select>
                            </el-form-item>
                            <el-form ref="form_ali" :model="form_ali" :rules="rules_ali" label-width="150px" v-show="dxchoose == 'ali'">
                                <el-form-item label="AccessKeyId" prop="app_id">
                                    <el-input v-model="form_ali.app_id" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="AccessKeySecret" prop="app_secret">
                                    <el-input v-model="form_ali.app_secret" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="SignName" prop="sms_sign_name">
                                    <el-input v-model="form_ali.sms_sign_name" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="TemplateCode" prop="sms_template_code">
                                    <el-input v-model="form_ali.sms_template_code" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="启用">
                                    <el-switch v-model="form_ali.enable" class="diainp"></el-switch>
                                </el-form-item>
                                <el-form-item>
                                    <el-button type="primary"  @click="onSaveSubmit('form_ali')">保存配置</el-button>
                                </el-form-item>
                            </el-form>
                            <el-form ref="form_wy" :model="form_wy" :rules="rules_wy" label-width="150px" v-show="dxchoose == 'wy'">
                                <el-form-item label="AppKey" prop="app_id">
                                    <el-input v-model="form_wy.app_id" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="AppSecret" prop="app_secret">
                                    <el-input v-model="form_wy.app_secret" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="TemplateId" prop="template_id">
                                    <el-input v-model="form_wy.template_id" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="启用">
                                    <el-switch v-model="form_wy.enable" class="diainp"></el-switch>
                                </el-form-item>
                                <el-form-item>
                                    <el-button type="primary" @click="onSaveSubmit('formWy')">保存配置</el-button>
                                </el-form-item>
                            </el-form>
                            <el-form ref="formNone" :model="form_none" label-width="150px" v-show="dxchoose == 'none'">
                                <el-form-item>
                                    <el-button type="primary" @click="onSaveSubmit('formNone')">保存配置</el-button>
                                </el-form-item>
                            </el-form>

                        </el-form>
                    </el-form>
                </el-tab-pane>

                <el-tab-pane label="基本设置" name="base_setting">
                    <div class="form-box tab-cont form-box2 flex-container">
                        <div class="left-side">
                            <el-form ref="form_base" :model="form_base" :rules="rules_base" label-width="150px">
                                <el-form-item label="跳转" prop="portal_url">
                                    <el-input v-model="form_base.portal_url" class="diainp"></el-input>
                                </el-form-item>
                                <el-form-item label="时间" prop="duration">
                                    <el-select v-model="form_base.duration" class="diainp" placeholder="请选择" @change="changeDuration">
                                        <el-option
                                            v-for="item in durations"
                                            :key="item"
                                            :label="item"
                                            :value="item">
                                        </el-option>
                                    </el-select>
                                    <span style="padding:5px 12px;">小时</span>
                                </el-form-item>
                                <el-form-item label="客户超时认证时间" prop="client_timeout">
                                    <el-select v-model="form_base.client_timeout" class="diainp" placeholder="请选择" @change="changeClientTimeout">
                                        <el-option
                                            v-for="item in client_timeout_op"
                                            :key="item"
                                            :label="item"
                                            :value="item">
                                        </el-option>
                                    </el-select>
                                    <span style="padding:5px 12px;">分钟</span>
                                </el-form-item>
                                <el-form-item label="背景图片" prop="background_url">
                                    <el-upload
                                        class="upload-demo"
                                        :action="uploadBgImage"
                                        ref="upload"
                                        name="file_name"
                                        with-credentials="true"
                                        list-type="picture"
                                        :limit="1"
                                        :data="uploadData"
                                        :before-upload="beforeUpload"
                                        :on-success="uploadSuccess"
                                        :on-excceed="handleExceed"
                                        v-model="fileList"
                                        accept="image/png,image/jpg"
                                        :auto-upload="true">
                                        <el-button slot="trigger" size="small" type="primary" v-if="fileList.length < 1">选取图片</el-button>
                                        <div slot="tip" class="el-upload__tip">只能上传jpg/png文件,且不超过2M</div>
                                    </el-upload>
                                </el-form-item>
                                <el-form-item>
                                    <el-button type="primary" @click="onSaveSubmit('form_base')">保存配置</el-button>
                                </el-form-item>
                            </el-form>
                        </div>

                        <div class="right-side">
                            <div v-if="form_base.background_url" class="phone-preview" :style="{ backgroundImage: 'url(' + form_base.background_url + ')' }">
                            </div>
                        </div>
                    </div>
                </el-tab-pane>

            </el-tabs>
        </div>

    </div>
</template>

<script>
    import { baseUrl } from 'components/common/Global';
    import {
        validateUrl,
        validateNum,
        validateTimeNum,
        validateSpace,
        validateMac,
        splitStr,
        validateAppId,
        formatMoney,
        convertMoney
    } from 'components/common/Helpers.js';

    export default {
        data: function () {
            return {
                params:{},
                task_type:'wxpay_setting',
                durations:[1,2,3,4,5,6,7,8,9,10,11,12],
                client_timeout_op:[2,4,6,8,10,20,30,60,120,360],
                form_wxpay: {
                    mch_id: '',
                    mch_serial_no: '',
                    mch_v3_key: '',
                    mch_priv_key: '',
                    wx_cert: '',
                    app_id: '',
                    amount: '',
                    notify_domain: '',
                    notify_url: '',
                    desc: '',
                    enable: false,
                    from_server: true,
                },
                rules_wxpay: {
                    mch_id: [
                        {required: true, message: '请输入商户号', trigger: 'blur'},
                        {validator: validateNum, trigger: 'blur'}
                    ],
                    mch_serial_no: [
                        {required: true, message: '请输入商户API证书序列号', trigger: 'blur'}
                    ],
                    mch_v3_key: [
                        {required: true, message: '请输入商户APIv3密钥', trigger: 'blur'}
                    ],
                    mch_priv_key: [
                        {required: true, message: '请上传商户私钥文件', trigger: 'blur'}
                    ],
                    wx_cert: [
                        {required: true, message: '请上传微信支付平台证书', trigger: 'blur'}
                    ],
                    app_id: [
                        {required: true, message: '请输入公众号或者小程序AppID', trigger: 'blur'},
                        {validator: validateAppId, trigger: 'blur'}
                    ],
                    amount: [
                        {required: true, message: '请输入支付金额', trigger: 'blur'},
                        {validator: validateNum, trigger: 'blur'}
                    ],
                    notify_domain: [
                        {required: true, message: '请输入通知域名', trigger: 'blur'},
                    ],
                    desc: [
                        {required: true, message: '请输入支付描述', trigger: 'blur'}
                    ]
                },
                form_onekey: {
                    enable: true,
                    from_server: true,
                },
                form_user: {
                    username:'apfree',
                    password:'apfree',
                    enable: true,
                    from_server: true,
                },
                rules_user: {
                    username:[
                        { required: true, message: '请输入用户名', trigger: 'blur'}
                    ],
                    password:[
                        { required: true, message: '请输入用户名密码', trigger: 'blur'}
                    ]
                },
                form_base: {
                    portal_url:'',
                    duration:'',
                    client_timeout:'',
                    background_url:'',
                },
                rules_base: {
                    portal_url: [
                        {required: true, message: '请输入跳转页面', trigger: 'blur'}
                    ],
                    duration: [
                        {required: true, message: '请选择时长', trigger: 'change'}
                    ],
                    client_timeout: [
                        {required: true, message: '选择客户超时认证时间', trigger: 'change'}
                    ],
                },
                form_dx:{

                },
                form_ali:{
                    app_id:'',
                    app_secret:'',
                    sms_sign_name:'',
                    sms_template_code:'',
                    enable:false,
                    from_server: true,
                },
                rules_ali: {
                    app_id: [
                        {required: true, message: '请输入AccessKeyId', trigger: 'blur'},
                    ],
                    app_secret: [
                        {required: true, message: '请输入AccessKeySecret', trigger: 'blur'}
                    ],
                    sms_sign_name: [
                        {required: true, message: '请输入SignName', trigger: 'blur'}
                    ],
                    sms_template_code:[
                        {required: true, message: '请输入TemplateCode', trigger: 'blur'}
                    ]

                },
                form_wy:{
                    app_id:'',
                    app_secret:'',
                    template_id:'',
                    enable: false,
                    from_server: true,
                },
                rules_wy: {
                    app_id: [
                        {required: true, message: '请输入AppKey', trigger: 'blur'},
                    ],
                    app_secret: [
                        {required: true, message: '请输入AppSecret', trigger: 'blur'}
                    ],
                    template_id: [
                        {required: true, message: '请输入TemplateId', trigger: 'blur'}
                    ]

                },
                form_none:{
                    enable:false,
                },
                dxchoose:'none',
                uploadBgImage: baseUrl + '/setting/uploadBgImage',
                uploadData: {},
                fileList: [],
                uploadKey: baseUrl + '/setting/uploadKey',
                mch_priv_key_filelist: [],
                uploadCert: baseUrl + '/setting/uploadCert',
                wx_cert_filelist: [],
                loading:false
            }
        },
        created:function () {
            this.getData();
        },
        methods: {
            validateUrl: validateUrl,
            validateNum: validateNum,
            validateTimeNum: validateTimeNum,
            validateSpace: validateSpace,
            validateMac: validateMac,
            splitStr: splitStr,
            validateAppId: validateAppId,
            formatMoney: formatMoney,
            convertMoney: convertMoney,
            
            onSaveSubmit: function(form_name){
                const self = this;
                self.$refs[form_name].validate(function (valid) {
                    if (!valid) {
                        return false;
                    }

                    self.params.user_account = localStorage.getItem('ms_username');
                    if (self.form_wxpay.enable) { 
                        self.params.wxpay = {
                            appId: self.form_wxpay.app_id,
                            mchId: self.form_wxpay.mch_id,
                            mchSerialNo: self.form_wxpay.mch_serial_no,
                            mchV3Key: self.form_wxpay.mch_v3_key,
                            mchPrivKey: self.form_wxpay.mch_priv_key,
                            wxCert: self.form_wxpay.wx_cert,
                            amount: convertMoney(self.form_wxpay.amount),
                            notifyDomain: self.form_wxpay.notify_domain,
                            desc: self.form_wxpay.desc,
                            enable: self.form_wxpay.enable,
                        };
                    } else {
                        self.params.wxpay = {
                            enable: false
                        };
                    }

                    if (self.form_onekey.enable) {
                        self.params.onekey = {
                            enable: self.form_onekey.enable,
                            fromServer: self.form_onekey.from_server
                        };
                    } else {
                        self.params.onekey = {
                            enable: false
                        };
                    }
                    
                    if (self.form_user.from_server) {
                        self.params.user = {
                            user:self.form_user.username,
                            password:self.form_user.password,
                            enable:self.form_user.enable,
                            fromServer:self.form_user.from_server,
                        };
                    } else {
                        self.params.user.enable = false;
                    }
                    
                    if (self.dxchoose == 'ali') {
                        self.params.sms = {
                            aliAppId: self.form_ali.app_id,
                            aliAppSecret: self.form_ali.app_secret,
                            aliSmsSignName: self.form_ali.sms_sign_name,
                            aliSmsTemplateCode: self.form_ali.sms_template_code,
                            selected:self.dxchoose,
                            smsAliEnable: self.form_ali.enable,
                        };
                    } else if (self.dxchoose == 'wy') {
                        self.params.sms = {
                            wyAppId:self.form_wy.app_id,
                            wyAppSecret:self.form_wy.app_secret,
                            wyTemplateId:self.form_wy.template_id,
                            selected:self.dxchoose,
                            smsWyEnable:self.form_wy.enable,
                        }
                    } else {
                        self.params.sms = {
                            smsAliEnable:false,
                            smsWyEnable:false,
                        }
                    }

                    self.params.portalUrl = self.form_base.portal_url;
                    self.params.backgroundUrl = self.form_base.background_url || '/static/img/lg_pic.png';
                    self.params.duration = self.form_base.duration;
                    self.params.clientTimeout = self.form_base.client_timeout;
                    
                    self.loading = true;
                    self.$axios.post(baseUrl + '/setting/saveSetting',self.params).then(function (res) {
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
                });
            },

            getData: function(){//获取数据
                const self = this;
                const params = {
                    user_account:localStorage.getItem('ms_username')
                }
                self.$axios.post(baseUrl+'/setting/getSetting',params).then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        const result = res.data.extra;
                        
                        self.form_wxpay.app_id = result.wxpayAppId || '';
                        self.form_wxpay.mch_id = result.mchId || '';
                        self.form_wxpay.mch_serial_no = result.mchSerialNo || '';
                        self.form_wxpay.mch_v3_key = result.mchV3Key || '';
                        self.form_wxpay.mch_priv_key = result.mchPrivateKey || '';
                        self.form_wxpay.wx_cert = result.wxCert || '';
                        self.form_wxpay.amount = formatMoney(result.wxpayAmount || 1);
                        self.form_wxpay.notify_domain = result.wxpayNotifyDomain || '';
                        self.form_wxpay.notify_url = 'https://' + self.form_wxpay.notify_domain + '/api/v1/wxpay/notify';
                        self.form_wxpay.desc = result.wxpayDesc || '';
                        self.form_wxpay.enable = result.wxPayEnable || false;

                        self.form_base.portal_url = result.portalUrl || '';
                        self.form_base.duration = String(result.duration || '');
                        self.form_base.client_timeout = result.clientTimeout || '';
                        self.form_base.background_url = result.backgroundUrl || '/static/img/lg_pic.png';
                        
                        self.form_user.username = result.user || '';
                        self.form_user.password = result.password || '';
                        self.form_user.enable = result.userEnable || false;

                        if (result.onekeyEnable) {
                            self.form_onekey.enable = true;
                            self.form_onekey.from_server = result.onekeyFromServerEnable || true;
                        } else {
                            self.form_onekey.enable = false;
                            self.form_onekey.from_server = false;
                        }
                        
                        self.form_ali.app_id = result.smsAliAppId || '';
                        self.form_ali.app_secret = result.smsAliAppSecret || '';
                        self.form_ali.sms_sign_name = result.smsAliSignName || '';
                        self.form_ali.sms_template_code = result.smsAliTemplateCode || '';
                        self.form_ali.enable = result.smsAliEnable || false;

                        self.form_wy.app_id = result.smsWyAppId || '';
                        self.form_wy.app_secret = result.smsWyAppSecret || '';
                        self.form_wy.template_id = result.smsWyTemplateId || '';
                        self.form_wy.enable = result.smsWyEnable || false;

                        self.dxchoose = result.smsSelected || 'none';
                    }
                })
            },

            updateNotifyUrl: function(e){
                const self = this;
                self.notify_url = 'https://' + e + '/api/v1/wxpay/notify';
            },

            changeDxchoose: function(e){
                const self = this;
                self.dxchoose = e;
            },

            changeDuration: function(value){
                const self = this;
                self.form_base.duration = String(value);
            },

            changeClientTimeout: function(value) {
                const self = this;
                self.form_base.client_timeout = String(value);
            },

            beforeUpload: function(file) {
                const isLt2M = file.size / 1024 / 1024 < 2;

                if (!isLt2M) {
                    this.$message({ message: '上传图片大小不能超过 2MB!', type: 'warning' });
                    return false;
                }

                return true;
            },

            beforeWxpayUpload: function(file){
                const isLt128K = file.size / 1024 < 128;
                if (!isLt128K) {
                    this.$message({message:'上传文件大小不能超过 128KB!',type:'warning'});
                    return false;
                }
                return true;
            },

            uploadSuccess: function(response, file, fileList) {
                if (response.ret_code == 0) {
                    file.response = response.extra;
                    if (file.response.type == 'cert') {
                        this.form_wxpay.wx_cert = file.response.url;
                        this.wx_cert_filelist = fileList;
                    } else if (file.response.type == 'key') {
                        this.form_wxpay.mch_priv_key = file.response.url;
                        this.mch_priv_key_filelist = fileList;
                    } else if (file.response.type == 'bgImage') {
                        this.form_base.background_url = file.response.url;
                        this.fileList = fileList;
                    } else {
                        this.$message.error('上传文件类型错误');
                    }
                } else {
                    this.$message.error(response.extra);
                }
            },

            handleExceed: function(files, fileList) {
                this.$message.error('只能上传一张图片');
            },
        }
    }
</script>
<style scoped>
    .flex-container {
        display: flex;
    }

    .left-side {
        flex: 1;
        padding-right: 80px;
    }

    .right-side {
        flex: 1;
        display: flex;
        justify-content: center;
        align-items: center;
        padding-left: 80px;
    }

    .phone-preview {
        width: 200px; /* Adjusted width */
        height: 400px; /* Adjusted height */
        border: 16px solid black;
        border-radius: 36px;
        background-size: cover;
        background-position: center;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        position: relative;
        background-color: #fff; /* White background to resemble an iPhone */
    }

    .phone-preview::before {
        content: '';
        position: absolute;
        width: 60px; /* Adjusted width */
        height: 5px;
        background-color: #333;
        border-radius: 10px;
        top: 10px;
        left: 50%;
        transform: translateX(-50%);
    }

    .phone-preview::after {
        content: '';
        position: absolute;
        width: 35px; /* Adjusted width */
        height: 35px; /* Adjusted height */
        background-color: #333;
        border-radius: 50%;
        bottom: 20px; /* Adjusted position */
        left: 50%;
        transform: translateX(-50%);
    }
    /* .last-cont{} */
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
