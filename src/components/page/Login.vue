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
            </el-form>
        </div>
        <div class="footer">
            <div class="p" id="communityFooter">
                技术支持&nbsp;<i class="fa fa-comment"></i>&nbsp;: &nbsp;<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5StVwau">QQ群(424031785)群主</a>
            </div>
        </div>
    </div>
</template>

<script>
    import axios from 'axios';
    import md5 from 'js-md5';
    import global_ from 'components/common/Global';
    export default {
        data() {
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
                        { min: 3, max: 32, message: '长度在3到32个字符', trigger: 'blur' },
                        { pattern: /^\S*$/, message: '密码不能包含空格', trigger: 'blur' }
                    ]
                }
            }
        },
        methods: {
            submitForm(formName) {
                this.$refs[formName].validate((valid) => {
                    if (valid) {
                        let params = {
                            user_account: this.ruleForm.username,
                            user_password: md5(this.ruleForm.password)
                        };
                        this.$axios.post(global_.baseUrl + '/admin/login', params).then((res) => {
                            if (res.data.ret_code == 0) {
                                this.$message({ message: '登录成功！', type: 'success' });
                                localStorage.setItem('ms_username', this.ruleForm.username);
                                // Inlined getUser logic
                                this.$axios.post(global_.baseUrl + '/admin/info').then((userInfoRes) => {
                                    if (userInfoRes.data.ret_code == 0) {
                                        const user = userInfoRes.data.extra;
                                        localStorage.setItem('userType', user.userType);
                                        this.$router.push('/basetable');
                                    }
                                }).catch(error => {
                                    console.error('User info API error:', error);
                                    this.$message.error('Failed to fetch user info. Please try again.');
                                });
                            } else {
                                this.$message(res.data.extra);
                            }
                        }).catch(error => {
                            console.error('Login API error:', error);
                            this.$message.error('Login failed. Please try again.');
                        });
                    } else {
                        console.log('error submit!!');
                        return false;
                    }
                });
            },
            register() {
                this.$router.push('/register');
            }
        }
    }
</script>

<style scoped>
    @import '../../assets/css/theme.css';
</style>