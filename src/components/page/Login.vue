<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-left">
        <h2 class="login-title">欢迎登录</h2>
        <p class="login-subtitle">AWAS认证服务器管理平台</p>
        <el-tabs v-model="activeTab" stretch>
          <el-tab-pane label="密码登录" name="password">
            <el-form :model="ruleForm" :rules="rules" ref="ruleForm" label-width="0px" class="login-form">
              <el-form-item prop="username">
                <el-input v-model="ruleForm.username" placeholder="请输入账号">
                  <template #prefix><i class="el-icon-user"></i></template>
                </el-input>
              </el-form-item>
              <el-form-item prop="password">
                <el-input v-model="ruleForm.password" type="password" placeholder="请输入密码" show-password>
                  <template #prefix><i class="el-icon-lock"></i></template>
                </el-input>
              </el-form-item>
              <el-checkbox v-model="rememberMe">记住密码</el-checkbox>
              <div class="login-actions">
                <el-button type="primary" @click="submitForm('ruleForm')" class="login-button">登 录</el-button>
              </div>
            </el-form>
          </el-tab-pane>
          <el-tab-pane label="短信登录" name="sms">
            <div class="coming-soon">短信登录功能未开放</div>
          </el-tab-pane>
        </el-tabs>
      </div>
      <div class="login-right">
        <!-- 可设置背景图或svg图形 -->
      </div>
    </div>
  </div>
</template>

<script>
import md5 from 'js-md5';
import global_ from 'components/common/Global';

export default {
  data() {
    return {
      ruleForm: {
        username: '',
        password: ''
      },
      rememberMe: false,
      activeTab: 'password',
      rules: {
        username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 3, max: 32, message: '长度在3到32个字符', trigger: 'blur' },
          { pattern: /^\S*$/, message: '密码不能包含空格', trigger: 'blur' }
        ]
      }
    };
  },
  mounted() {
    document.addEventListener('keydown', this.handleEnterKey);
    // 等 DOM 渲染完毕后聚焦
    this.$nextTick(() => {
      const usernameInput = this.$el.querySelector('input[placeholder="请输入账号"]');
      if (usernameInput) {
        usernameInput.focus();
      }
    });
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.handleEnterKey);
  },
  methods: {
    handleEnterKey(event) {
      if (event.key === 'Enter') {
        this.submitForm('ruleForm');
      }
    },
    submitForm(formName) {
      this.$refs[formName].validate(valid => {
        if (!valid) return;

        const params = {
          user_account: this.ruleForm.username,
          user_password: md5(this.ruleForm.password)
        };

        this.$axios
          .post(global_.baseUrl + '/admin/login', params)
          .then(res => {
            if (res.data.ret_code === 0) {
              this.$message.success('登录成功');
              localStorage.setItem('ms_username', this.ruleForm.username);

              this.$axios.post(global_.baseUrl + '/admin/info').then(userInfoRes => {
                if (userInfoRes.data.ret_code === 0) {
                  const user = userInfoRes.data.extra;
                  localStorage.setItem('userType', user.userType);
                  this.$router.push('/basetable');
                }
              });
            } else {
              this.$message.error(res.data.extra);
            }
          })
          .catch(() => {
            this.$message.error('登录失败，请重试');
          });
      });
    }
  }
};
</script>

<style scoped>
  .login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    /* background: linear-gradient(135deg, #1a2980 0%, #26d0ce 100%); */
    background: linear-gradient(120deg, #1a2980 0%, #26d0ce 100%);

    height: 100vh;
    overflow: hidden;
  }

  .login-box {
    width: 900px;
    height: 500px;
    background: #fff;
    display: flex;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    border-radius: 12px;
    overflow: hidden;
  }

  .login-left {
    flex: 1;
    padding: 60px;
  }

  .login-title {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 5px;
  }

  .login-subtitle {
    color: #999;
    margin-bottom: 30px;
  }

  .login-form {
    margin-top: 10px;
  }

  .login-actions {
    margin-top: 20px;
  }

  .login-button {
    width: 100%;
    height: 42px;
    font-size: 16px;
    border-radius: 6px;
  }

  .coming-soon {
    text-align: center;
    color: #999;
    padding: 40px;
  }

  .login-right {
    flex: 1;
    background: url('/static/img/login-bg.svg') no-repeat center;
    background-size: cover;
  }
</style>
