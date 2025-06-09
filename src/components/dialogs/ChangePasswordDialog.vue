<template>
  <el-dialog title="修改密码" :visible.sync="isVisible" @close="closeDialog" class="digcont">
    <el-form :model="form" :rules="rules" ref="changePasswordForm">
      <el-form-item label="原密码" prop="user_password" :label-width="formLabelWidth">
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
      <el-button @click="closeDialog">取 消</el-button>
      <el-button type="primary" @click="save" :loading="loading">确 定</el-button>
    </div>
  </el-dialog>
</template>

<script>
import md5 from 'js-md5';

export default {
  name: 'ChangePasswordDialog',
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    formLabelWidth: {
      type: String,
      default: '120px',
    },
    targetAccount: {
      type: String,
      required: true,
    },
  },
  data() {
    const validateRepwd = (rule, value, callback) => {
      if (value !== this.form.user_new_password) {
        callback(new Error('两次输入密码不一致'));
      } else {
        callback();
      }
    };
    return {
      form: {
        user_password: '',
        user_new_password: '',
        user_validate_password: '',
      },
      rules: {
        user_password: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
        user_new_password: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
        user_validate_password: [
          { required: true, message: '请输入确认密码', trigger: 'blur' },
          { validator: validateRepwd, trigger: 'blur' },
        ],
      },
      loading: false,
    };
  },
  computed: {
    isVisible: {
      get() {
        return this.visible;
      },
      set(value) {
        this.$emit('update:visible', value);
      },
    },
  },
  watch: {
    visible(newVal) {
      if (newVal) {
        this.resetForm();
      }
    },
  },
  methods: {
    resetForm() {
      if (this.$refs.changePasswordForm) {
        this.$refs.changePasswordForm.resetFields();
      }
      this.form = {
        user_password: '',
        user_new_password: '',
        user_validate_password: '',
      };
      this.loading = false;
    },
    closeDialog() {
      this.isVisible = false;
      this.$emit('close');
    },
    save() {
      this.$refs.changePasswordForm.validate((valid) => {
        if (valid) {
          this.loading = true;
          const dataToSave = {
            user_account: this.targetAccount,
            user_password: md5(this.form.user_password),
            user_new_password: md5(this.form.user_new_password),
          };
          this.$emit('save', dataToSave);
        } else {
          // console.log('Validation failed for Change Password Dialog'); // Removed
          return false;
        }
      });
    },
    onSaveSuccess() {
        this.loading = false;
        this.closeDialog();
    },
    onSaveError() {
        this.loading = false;
    }
  },
};
</script>

<style scoped>
.digcont {
}
.diainp {
  width: 217px;
}
.dialog-footer {
  text-align: right;
}
</style>
