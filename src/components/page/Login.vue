<template>
  <div class="login-container">
    <!-- 加载状态 -->
    <div v-if="loading" class="loading-overlay" v-loading="loading"></div>

    <!-- 登录表单 -->
    <div v-else class="login-box">
      <div class="login-left">
        <h2 class="login-title">欢迎登录</h2>
        <p class="login-subtitle">{{ systemInfo.systemName || 'AWAS认证服务器管理平台' }}</p>
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
      <footer class="login-footer">
        <p>{{ systemInfo.copyright || '© 2025 AWAS认证服务器管理平台' }} {{ 'ICP备案号: ' }} {{ systemInfo.icpRecord || '京ICP备12345678号' }}</p>
      </footer>
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
      },
      loading: true, // 加载状态
      systemInfo: {} // 系统信息
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
    this.fetchSystemInfo();
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
    // 获取系统信息
    fetchSystemInfo() {
      this.$axios
        .get(global_.baseUrl + '/sysinfo/detail')
        .then(res => {
          if (res.data.ret_code === 0) {
            this.systemInfo = res.data.extra;
            localStorage.setItem('systemName', res.data.extra.systemName);
            localStorage.setItem('logoUrl', res.data.extra.logo);
            document.title = res.data.extra.systemName || 'AWAS认证服务器管理平台';
          } else {
            this.$message.error('获取系统信息失败');
          }
        })
        .catch(() => {
          this.$message.error('获取系统信息失败');
        })
        .finally(() => {
          this.loading = false; // 无论成功或失败都关闭加载状态
        });
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
    background: linear-gradient(120deg, #1a2980 0%, #26d0ce 100%);
    height: 100vh;
    overflow: hidden;
    position: relative;
  }

  .login-box {
    width: 900px;
    height: 500px;
    background: #fff;
    display: flex;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    border-radius: 12px;
    overflow: hidden;
    z-index: 1;
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

  .login-footer {
    width: 100%;
    text-align: center;
    padding: 10px 0;
    position: absolute;
    bottom: 0;
    left: 0;
    font-size: 12px;
    color: #3b3a41;
    z-index: 2;
  }

  /* 加载状态样式 */
  .loading-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(255, 255, 255, 0.8);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 10;
  }

  .loading-spinner {
    text-align: center;
  }

  .loading-spinner p {
    margin-top: 16px;
    color: #666;
  }
</style>  