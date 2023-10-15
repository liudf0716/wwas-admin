<template>
    <div class="login-wrap">
        <div class="ms-title">认证服务器管理平台</div>
        <div class="ms-login">
            <el-form :model="ruleForm" :rules="rules" ref="ruleForm" label-width="0px" class="demo-ruleForm">
                <el-form-item prop="username">
                    <el-input v-model="ruleForm.username" placeholder="账号"></el-input>
                </el-form-item>
                <el-form-item prop="password">
                    <el-input type="password" placeholder="密码" v-model="ruleForm.password" @keyup.enter.native="submitForm('ruleForm')"></el-input>
                </el-form-item>
                <div class="login-btn">
                    <el-button type="primary" @click="submitForm('ruleForm')">登录</el-button>
                </div>
                <div class="login-btn login-btn-a-cont">
                    <el-button class="login-btn-btn" type="text" @click="register">用户注册</el-button>
                    <!--<a class="login-btn-a" href="https://jq.qq.com/?_wv=1027&k=5StVwau" target="_blank">-->
                        <!--<el-button type="defult">用户注册</el-button>-->
                    <!--</a>-->
                </div>
                <p style="font-size:12px;line-height:30px;color:#aaa;">用户注册请先加群联系相关人员</p>
            </el-form>
        </div>
        <div class="footer">
            <div class="p" id="communityFooter">
                Community&nbsp;<i class="fa fa-comment"></i>&nbsp;: &nbsp;<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5StVwau">QQ群(424031785)</a>
                <!--&nbsp;&nbsp;|&nbsp;&nbsp;-->
                <!--<iframe src="http://ghbtns.com/github-btn.html?user=liudf0716&amp;repo=node-open-mining-portal&amp;type=watch&amp;count=true" allowtransparency="true" frameborder="0" scrolling="0" width="140" height="20"></iframe>-->
            </div>

        </div>
    </div>
</template>
<script>
    import axios from 'axios';
    import  md5 from 'js-md5';
    import global_ from 'components/common/Global';
    export default {
        data: function(){
            return {
                ruleForm: {
                    username: '',
                    password: ''
                },
                rules: {
                    username: [
                        { required: true, message: '请输入用户名', trigger: 'blur' }
                    ],
                    password: [
                        { required: true, message: '请输入密码', trigger: 'blur' },
                        {min:3,max:32,message:'长度在3到32个字符',trigger:'blur'},
                        {validator:function(rule,value,callback){
                            if(value.indexOf(' ') != -1){
                                callback(new Error('密码不能包含空格'));
                            }else{
                                callback();
                            }
                        }}
                    ]
                }
            }
        },
        created:function(){
            this.getData();
        },
        methods: {
            getData: function(){
                let self = this;
            },
            getUser: function(){
                var self = this;
                self.$axios.post(global_.baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == 0){
                        localStorage.setItem('userMsg',res.data.ret_msg);
                        if(res.data.ret_msg == '1'){//普通管理员

                        }
                        self.$router.push('/basetable')
                    }
                })
            },
            submitForm:function(formName) {
                const self = this;
                self.$refs[formName].validate(function(valid){
                    if (valid) {
                        let params = {
                            user_account: self.ruleForm.username,
                            user_password: md5(self.ruleForm.password)
                            // user_password: self.ruleForm.password
                        };
                        self.$axios.post(global_.baseUrl + '/admin/login',params).then(function(res){
                            // console.log(res);
                            if(res.data.ret_code == 0){
                                self.$message({message:'登录成功！',type:'success'});
                                localStorage.setItem('ms_username',self.ruleForm.username);
                                self.getUser();
                            }else{
                                self.$message(res.data.extra);
                            }

                        },function(err){
                            console.log(err);
                        })


                    } else {
                        console.log('error submit!!');
                        return false;
                    }
                });
            },
            register: function(){
                let self = this;
                self.$router.push('/register');
            }
        }
    }
</script>

<style scoped>
    .login-btn-a-cont{
        margin-top:15px;
    }
    .login-btn-a{
        /*display: inline-block;*/
        /*width:100%;*/
        /*height:36px;*/
        /*line-height: 36px;*/
        /*font-size:14px;*/
        /*color:#4db3ff;*/
        margin:15px 0 0 0;
        /*border:1px solid #4db3ff;*/
        /*border-radius: 3px;*/
    }
    .login-btn-btn{
        color:#4db3ff;
        background-color:#fff;
        border:1px solid #4db3ff;
        border-radius: 3px;
    }
    .login-btn-a:hover{
        /*background-color:#f5f5f5;*/
    }
    .login-wrap{
        position: relative;
        width:100%;
        height:100%;
    }
    .ms-title{
        position: absolute;
        top:50%;
        width:100%;
        margin-top: -230px;
        text-align: center;
        font-size:30px;
        color: #fff;

    }
    .ms-login{
        position: absolute;
        left:50%;
        top:50%;
        width:300px;
        height:210px;
        margin:-150px 0 0 -190px;
        padding:40px;
        border-radius: 5px;
        background: #fff;
    }
    .login-btn{
        text-align: center;
    }
    .login-btn button{
        width:100%;
        height:36px;
    }
    .footer{
        position: absolute;
        box-sizing: border-box;
        width: 100%;
        color: #999;
        text-align: center;
        font-size:14px;
        margin-top:30px;
        border-top:1px solid rgba(60,60,60,.4);
        padding-top:30px;
        bottom:0;
        padding-bottom:30px;
    }
    .footer .p{
        height:30px;
        line-height:30px;
    }
    .footer a{
        font-size:15px;
        color:#4db3ff;
    }
</style>
