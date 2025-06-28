<template>
  <el-dialog title="删除路由" :visible.sync="isVisible" @close="closeDialog" class="digcont">
    <div style="margin-bottom: 16px">*批量添加功能MAC之间以换行分割，每行一个MAC；MAC格式为12位字母或数字组合，不区分大小写:</div>
    <el-form :model="form" ref="deleteRouterForm" :rules="rules">
      <el-form-item prop="route_mac">
        <el-input type="textarea" :rows="5" placeholder="请输入内容" v-model="form.route_mac"></el-input>
      </el-form-item>
    </el-form>
    <div class="mt30 dialog-footer">
      <el-button @click="closeDialog">取 消</el-button>
      <el-button type="primary" @click="save" :loading="loading">保 存</el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'DeleteRouterDialog',
  props: {
    visible: { type: Boolean, default: false },
    targetAccount: { type: String, required: true }
  },
  data() {
    const validateMacInForm = (rule, value, callback) => {
      if (!value) {
        return callback(new Error('MAC地址不能为空'));
      }
      const regMac1 = /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
      const regMac2 = /^[A-Fa-f\d]{12}$/;
      const macs = this.splitStringByCommaOrNewline(value);
      if (macs.length === 0 && value.trim() !== '') {
        return callback(new Error('请输入有效的MAC地址'));
      }
      for (const mac of macs) {
        if (mac && !regMac1.test(mac) && !regMac2.test(mac)) {
          return callback(new Error('MAC输入有误 (' + mac + ')，请检查格式和分隔符'));
        }
      }
      callback();
    };
    return {
      form: {
        route_mac: ''
      },
      rules: {
        route_mac: [
          { required: true, message: '请输入MAC地址', trigger: 'blur' },
          { validator: validateMacInForm, trigger: 'blur' }
        ]
      },
      loading: false
    };
  },
  computed: {
    isVisible: {
      get() {
        return this.visible;
      },
      set(value) {
        this.$emit('update:visible', value);
      }
    }
  },
  watch: {
    visible(newVal) {
      if (newVal) {
        this.resetForm();
      }
    }
  },
  methods: {
    resetForm() {
      if (this.$refs.deleteRouterForm) {
        this.$refs.deleteRouterForm.resetFields();
      }
      this.form.route_mac = '';
      this.loading = false;
    },
    closeDialog() {
      this.isVisible = false;
      this.$emit('close');
    },
    save() {
      this.$refs.deleteRouterForm.validate(valid => {
        if (valid) {
          this.loading = true;
          const dataToSave = {
            user_name: this.targetAccount,
            route_mac: this.form.route_mac
          };
          this.$emit('save', dataToSave);
        } else {
          // console.log('Validation failed for Delete Router Dialog'); // Removed
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
    },
    splitStringByCommaOrNewline(str) {
      if (!str) return [];
      return str
        .split(/[\n,]/g)
        .map(s => s.trim())
        .filter(s => s !== '');
    }
  }
};
</script>

<style scoped>
  .digcont {
  }
  .mt30 {
    margin-top: 30px;
  }
  .dialog-footer {
    text-align: right;
  }
</style>
