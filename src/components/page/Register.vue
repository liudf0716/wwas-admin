<template>
    <div class="login-wrap">
        <div class="ms-title">用户注册</div>
        <div class="ms-login">
            <el-form :model="ruleForm" :rules="rules" ref="ruleForm" label-width="80px" class="demo-ruleForm">
                <el-form-item label="手机号" prop="account">
                    <el-input v-model="ruleForm.account" placeholder="请输入手机号码"></el-input>
                </el-form-item>
                <el-form-item label="密码" prop="password">
                    <el-input type="password" placeholder="密码" v-model="ruleForm.password" @keyup.enter.native="submitForm('ruleForm')"></el-input>
                </el-form-item>
                <el-form-item label="用户名" prop="name" style="display: none;">
                    <el-input v-model="ruleForm.name" placeholder="用户名"></el-input>
                </el-form-item>
                <el-form-item label="联系方式" prop="phone" style="display: none;">
                    <el-input v-model="ruleForm.phone" placeholder="电话号码"></el-input>
                </el-form-item>
                <el-form-item label="所在城市" prop="city" style="display: none;">
                    <el-select size="small" style="width: 110px"
                               v-model="ruleForm.selectProv"
                               placeholder="请选择省份"
                               v-on:change="getProv($event)">
                        <el-option
                            v-for="item in provs"
                            :key="item.label"
                            :label="item.label"
                            :value="item.value">
                        </el-option>
                    </el-select>
                    <el-select size="small" style="width: 104px"
                               v-if="ruleForm.selectProv!=''"
                               v-model="ruleForm.selectCity"
                               placeholder="请选择城市"
                               v-on:change="getCity($event)">
                        <el-option
                            v-for="item in citys"
                            :key="item.label"
                            :label="item.label"
                            :value="item.value">
                        </el-option>
                    </el-select>
                </el-form-item>
                <div class="login-btn">
                    <el-button type="primary" @click="submitForm('ruleForm')">注 册</el-button>
                </div>
                <div class="login-btn">
                    <el-button class="login-btn-btn" type="text" @click="back">返回登录</el-button>
                </div>
            </el-form>
        </div>
    </div>
</template>

<script>
    import axios from 'axios';
    import global_ from 'components/common/Global';
    import  md5 from 'js-md5';
    export default {
        data: function(){
            return {
                ruleForm: {
                    account: '',
                    password: '',
                    name:'',
                    phone:'',
                    city:'',
                    selectProv: '',
                    selectCity: '',
                },
                provs:global_.provs,
                citys: [],
                rules: {
                    account: [
                        { required: true, message: '请输入手机号码', trigger: 'blur' }
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
                    ],
                }
            }
        },
        created:function(){

        },
        methods: {
            submitForm:function(formName) {
                const self = this;
                self.$refs[formName].validate(function(valid){
                    if (valid) {
                        var params = {
                            user_account: self.ruleForm.account,
                            user_password: md5(self.ruleForm.password),
                            user_name: self.ruleForm.account,
                            user_phone:self.ruleForm.account,
                            user_city:self.ruleForm.selectProv + self.ruleForm.selectCity

                        };
                        //console.log(params);
                        self.$axios.post(global_.baseUrl + '/admin/register',params).then(function(res){
                            //console.log(res);
                            if(res.data.ret_code == 0){
                                self.$message('注册成功！');
                                // localStorage.setItem('ms_username',self.ruleForm.account);
                                // localStorage.setItem('storgePwd',self.ruleForm.password);
//                        self.$router.push('/readme');
                                self.$router.push('/login');
                            }else{
                                self.$message(res.data.extra);
                            }

                        },function(err){
                            console.log(err);
                        });
                    } else {
                        console.log('error submit!!');
                        return false;
                    }
                });
            },
            back: function(){
                this.$router.push('/login');
            }
        }
    }
</script>

<style scoped>
    .login-wrap{
        position: relative;
        width:100%;
        height:100%;
    }
    .ms-title{
        position: absolute;
        top:46%;
        width:100%;
        margin-top: -230px;
        text-align: center;
        font-size:30px;
        color: #fff;

    }
    .ms-login{
        position: absolute;
        left:50%;
        top:46%;
        width:300px;
        /*height:160px;*/
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
    .login-btn-btn{
        color:#4db3ff;
        margin:15px 0 0 0;
        background-color:#fff;
        border:1px solid #4db3ff;
        border-radius: 3px;
    }
</style>
