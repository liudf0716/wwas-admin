<template>
  <div class="header">
    <div class="logo"><img class="header-logo" :src="logoUrl" />{{ systemName }}</div>
    <div class="user-info">
      <el-dropdown trigger="click" @command="handleCommand">
        <span class="el-dropdown-link">
          <img class="user-logo" src="../../../static/img/img.jpg" />
          {{ username }}
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item command="changepwd">修改密码</el-dropdown-item>
          <el-dropdown-item command="loginout">退出</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>

    <el-dialog title="修改密码" :visible.sync="showDialogPwd" class="digcont">
      <el-form :model="form" ref="form" :rules="rules">
        <!--<el-form-item label="账号" prop="user_account" :label-width="formLabelWidth">-->
        <!--<el-input v-model="form.user_account" class="diainp" auto-complete="off"></el-input>-->
        <!--</el-form-item>-->
        <el-form-item label="密码" prop="user_password" :label-width="formLabelWidth">
          <el-input v-model="form.user_password" type="password" class="diainp" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="user_new_password" :label-width="formLabelWidth">
          <el-input v-model="form.user_new_password" type="password" class="diainp" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="user_validate_password" :label-width="formLabelWidth">
          <el-input v-model="form.user_validate_password" type="password" class="diainp" auto-complete="off"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="showDialogPwd = false">取 消</el-button>
        <el-button type="primary" @click="saveChange('form')">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import md5 from 'js-md5';
import global_ from 'components/common/Global';
export default {
  data() {
    return {
      name: 'linxin',
      showDialogPwd: false,
      username: localStorage.getItem('ms_username') || '未登录',
      logoUrl: localStorage.getItem('logoUrl') || require('../../../static/img/logo.png'),
      systemName: localStorage.getItem('systemName'),
      form: {
        user_account: localStorage.getItem('ms_username'),
        user_password: '',
        user_new_password: '',
        user_validate_password: ''
      },
      formLabelWidth: '120px',
      rules: {
        user_account: [{ required: true, message: '请输入账号', trigger: 'blur' }],
        user_password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { validator: this.validateSpace, trigger: 'blur' },
          { min: 3, max: 32, message: '长度在3到32个字符', trigger: 'blur' }
        ],
        user_new_password: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { validator: this.validateSpace, trigger: 'blur' },
          { min: 3, max: 32, message: '长度在3到32个字符', trigger: 'blur' }
        ],
        user_validate_password: [
          { required: true, message: '请输入确认密码', trigger: 'blur' },
          { validator: this.validateRepwd, trigger: 'blur' }
        ]
      }
    };
  },
  mounted() {
    this.$bus.$on('updateSysinfo', data => {
      this.logoUrl = data.logo || require('../../../static/img/logo.png');
      this.systemName = data.systemName;
    });
  },
  methods: {
    saveChange: function (formName) {
      var self = this;
      self.$refs[formName].validate(function (valid) {
        if (valid) {
          var params = {
            user_account: md5(self.form.user_account),
            user_password: md5(self.form.user_password),
            user_new_password: md5(self.form.user_new_password)
          };
          self.$axios.post(global_.baseUrl + '/admin/change', params).then(
            function (res) {
              if (res.data.ret_code == '1001') {
                self.$message({ message: res.data.extra, type: 'warning' });
                setTimeout(function () {
                  self.$router.replace('login');
                }, 2000);
              }
              if (res.data.ret_code == 0) {
                self.showDialogPwd = false;
                self.$message({ message: res.data.extra, type: 'success' });

                self.$axios.post(global_.baseUrl + '/admin/logout').then(
                  function (res) {
                    //退出重新登录
                    if (res.data.ret_code == '1001') {
                      self.$message({ message: res.data.extra, type: 'warning' });
                      setTimeout(function () {
                        self.$router.replace('login');
                      }, 2000);
                    }
                    if (res.data.ret_code == 0) {
                      // self.$message({message:res.data.extra,type:'success'});
                      localStorage.removeItem('ms_username');
                      localStorage.removeItem('userType');
                      self.$router.push('/login');
                    } else {
                      self.$message.error(res.data.extra);
                    }
                  },
                  function (err) {
                    self.$message.error(err);
                  }
                );
              } else {
                self.$message.error(res.data.extra);
              }
            },
            function (err) {
              //                    self.loading = false;
              self.$message.error(err);
            }
          );
        } else {
          console.log('error submit!!');
          return false;
        }
      });
    },
    validateRepwd: function (rule, value, callback) {
      if (value !== this.form.user_new_password) {
        callback(new Error('两次输入密码不一致'));
      } else {
        callback();
      }
    },
    validateSpace: function (rule, value, callback) {
      var self = this;
      if (value.indexOf(' ') >= 0) {
        callback(new Error('输入有空格'));
      } else {
        callback();
      }
    },
    handleCommand(command) {
      var self = this;
      if (command == 'changepwd') {
        self.showDialogPwd = true;
      }
      if (command == 'loginout') {
        self.$axios.post(global_.baseUrl + '/admin/logout').then(
          function (res) {
            if (res.data.ret_code == '1001') {
              self.$message({ message: res.data.extra, type: 'warning' });
              setTimeout(function () {
                self.$router.replace('login');
              }, 2000);
            }
            if (res.data.ret_code == 0) {
              self.$message({ message: res.data.extra, type: 'success' });
              localStorage.removeItem('ms_username');
              localStorage.removeItem('userType');
              self.$router.push('/login');
            } else {
              self.$message.error(res.data.extra);
            }
          },
          function (err) {
            self.$message.error(err);
          }
        );
      }
    }
  }
};
</script>
<style scoped>
  @import '../../assets/css/theme.css';
</style>
