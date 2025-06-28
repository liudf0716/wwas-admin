<template>
  <el-dialog :title="dialogTitle" :visible.sync="isVisible" @close="closeDialog" class="digcont">
    <el-form :model="form" ref="addUpdateGatewayForm" :rules="rules">
      <el-form-item label="设备ID" prop="device_id" :label-width="formLabelWidth" class="form-item-center">
        <el-tooltip effect="dark" content="设备ID用于标识整个设备，一个设备下有多个认证网关" placement="top">
          <el-input v-model="form.device_id" maxlength="12" style="width: 150px" :disabled="isUpdate"></el-input>
        </el-tooltip>
      </el-form-item>
      <el-form-item label="网关ID" prop="gw_id" :label-width="formLabelWidth" class="form-item-center">
        <el-tooltip effect="dark" content="认证网关ID，一般为每个桥接口的MAC地址，长度不超过12个字符" placement="top">
          <el-input v-model="form.gw_id" maxlength="12" style="width: 150px" :disabled="isUpdate"></el-input>
        </el-tooltip>
      </el-form-item>
      <el-form-item label="开启单次认证" prop="once_auth" :label-width="formLabelWidth" class="form-item-center">
        <el-switch v-model="form.once_auth" active-color="#13ce66" inactive-color="#ff4949"></el-switch>
      </el-form-item>
      <el-form-item v-if="form.once_auth" label="免认证时长" prop="next_auth_time" :label-width="formLabelWidth" class="form-item-center">
        <el-tooltip effect="dark" content="免认证时长单位为天，当有一个用户通过认证后，后续免认证时长内该网关不再需要认证" placement="top">
          <el-input v-model="form.next_auth_time" maxlength="12" style="width: 150px"></el-input>
        </el-tooltip>
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="closeDialog">取消</el-button>
      <el-button type="primary" @click="save" :loading="loading">{{ isUpdate ? '修改' : '添加' }}</el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'AddUpdateGatewayDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    formLabelWidth: {
      type: String,
      default: '120px'
    },
    isUpdate: {
      type: Boolean,
      default: false
    },
    initialData: {
      type: Object,
      default: () => ({
        device_id: '',
        gw_id: '',
        once_auth: false,
        next_auth_time: ''
      })
    }
  },
  data() {
    return {
      form: { ...this.initialData },
      loading: false,
      rules: {
        device_id: [{ required: true, message: '设备ID不能为空', trigger: 'blur' }],
        gw_id: [{ required: true, message: '网关ID不能为空', trigger: 'blur' }],
        next_auth_time: [
          {
            validator: (rule, value, callback) => {
              if (this.form.once_auth && !value) {
                callback(new Error('免认证时长不能为空'));
              } else if (this.form.once_auth && value && !/^\d+$/.test(value)) {
                // check value exists before regex
                callback(new Error('免认证时长必须为数字'));
              } else {
                callback();
              }
            },
            trigger: 'blur'
          }
        ]
      }
    };
  },
  computed: {
    dialogTitle() {
      return this.isUpdate ? '修改认证网关' : '添加认证网关';
    },
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
        this.resetFormAndLoadInitialData();
      }
    },
    initialData: {
      handler(newData) {
        this.form = { ...newData };
      },
      deep: true
    }
  },
  methods: {
    resetFormAndLoadInitialData() {
      if (this.$refs.addUpdateGatewayForm) {
        this.$refs.addUpdateGatewayForm.resetFields();
      }
      if (this.isUpdate) {
        this.form = { ...this.initialData };
      } else {
        this.form = {
          device_id: '',
          gw_id: '',
          once_auth: false,
          next_auth_time: ''
        };
      }
      this.loading = false;
    },
    closeDialog() {
      this.isVisible = false;
      this.$emit('close');
    },
    save() {
      this.$refs.addUpdateGatewayForm.validate(valid => {
        if (valid) {
          this.loading = true;
          const dataToSave = { ...this.form };
          this.$emit('save', dataToSave, this.isUpdate);
        } else {
          // console.log('Validation failed for Add/Update Gateway Dialog'); // Removed
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
  }
};
</script>

<style scoped>
  .digcont {
  }
  .form-item-center {
  }
  .dialog-footer {
    text-align: right;
  }
</style>
