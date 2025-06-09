<template>
  <el-dialog title="新建子渠道" :visible.sync="isVisible" @close="closeDialog" class="digcont">
    <el-form :model="form" :rules="rules" ref="newChannelForm">
      <el-form-item label="账号/渠道名称" prop="user" :label-width="formLabelWidth">
        <el-input v-model="form.user" class="diainp" auto-complete="off"></el-input>
      </el-form-item>
      <el-form-item label="密码" prop="password" :label-width="formLabelWidth">
        <el-input v-model="form.password" type="password" class="diainp" auto-complete="off"></el-input>
      </el-form-item>
       <el-form-item label="渠道名称" prop="name" :label-width="formLabelWidth">
        <el-input v-model="form.name" class="diainp" auto-complete="off"></el-input>
      </el-form-item>
      <el-form-item label="联系电话" prop="tel" :label-width="formLabelWidth">
        <el-input v-model="form.tel" class="diainp" auto-complete="off"></el-input>
      </el-form-item>
      <el-form-item label="地址" :label-width="formLabelWidth">
        <el-select
          size="small"
          style="width: 110px"
          v-model="form.selectProv"
          placeholder="请选择省份"
          @change="handleProvinceChangeInDialog"
        >
          <el-option v-for="item in provs" :key="item.value" :label="item.label" :value="item.value"></el-option>
        </el-select>
        <el-select
          size="small"
          style="width: 104px"
          v-if="form.selectProv"
          v-model="form.selectCity"
          placeholder="请选择城市"
          @change="handleCityChangeInDialog"
        >
          <el-option v-for="item in cityOptions" :key="item.value" :label="item.label" :value="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="" :label-width="formLabelWidth">
        <el-input v-model="form.addr" class="diainp2" auto-complete="off" placeholder="请输入详细地址"></el-input>
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="closeDialog">取 消</el-button>
      <el-button type="primary" @click="save">创 建</el-button>
    </div>
  </el-dialog>
</template>

<script>
import global_ from 'components/common/Global';
// import md5 from 'js-md5'; // Removed unused import

export default {
  name: 'NewChannelDialog',
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    formLabelWidth: {
      type: String,
      default: '120px',
    },
    initialProvs: {
        type: Array,
        default: () => []
    }
  },
  data() {
    return {
      form: {
        user: '',
        password: '',
        name: '',
        tel: '',
        selectProv: '',
        selectCity: '',
        addr: '',
      },
      rules: {
        user: [
          { required: true, message: '请输入账号', trigger: 'blur' },
          { validator: this.validateSpace, trigger: 'blur' },
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { validator: this.validateSpace, trigger: 'blur' },
          { min: 3, max: 32, message: '长度在3到32个字符', trigger: 'blur' },
        ],
        name: [
          { required: true, message: '请输入渠道名称', trigger: 'blur' },
          { validator: this.validateSpace, trigger: 'blur' },
        ],
        tel: [
          { required: true, message: '请输入联系电话', trigger: 'blur' },
          { validator: this.validateTel, trigger: 'blur' },
        ],
      },
      cityOptions: [],
      provs: [],
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
        this.provs = [...this.initialProvs];
      }
    },
    initialProvs: {
        handler(newProvs) {
            this.provs = [...newProvs];
        },
        immediate: true,
        deep: true
    }
  },
  methods: {
    validateSpace(rule, value, callback) {
      if (value && value.includes(' ')) {
        callback(new Error('输入内容不能包含空格'));
      } else {
        callback();
      }
    },
    validateTel(rule, value, callback) {
      const regTel = /(\(\d{3,4}\)|\d{3,4}-|\s)?\d{7,14}$/;
      if (!value) {
        callback(new Error('请输入联系电话'));
      } else if (!regTel.test(value)) {
        callback(new Error('电话号码输入有误！'));
      } else {
        callback();
      }
    },
    resetForm() {
      if (this.$refs.newChannelForm) {
        this.$refs.newChannelForm.resetFields();
      }
      this.form = {
        user: '',
        password: '',
        name: '',
        tel: '',
        selectProv: '',
        selectCity: '',
        addr: '',
      };
      this.cityOptions = [];
    },
    closeDialog() {
      this.isVisible = false;
      this.$emit('close');
    },
    save() {
      this.$refs.newChannelForm.validate((valid) => {
        if (valid) {
          const formData = {
            ...this.form,
          };
          this.$emit('save', formData);
        } else {
          return false;
        }
      });
    },
    handleProvinceChangeInDialog(provValue) {
      this.cityOptions = [];
      this.form.selectCity = '';
      if (!provValue) return;
      this.cityOptions = global_.allCity
        .filter(cityInfo => cityInfo.prov === provValue)
        .map(cityInfo => ({ label: cityInfo.label, value: cityInfo.value || cityInfo.label }));
    },
    handleCityChangeInDialog(cityValue) {
      // Intentionally left blank
    },
  },
};
</script>

<style scoped>
.digcont {
}
.diainp {
  width: 217px;
}
.diainp2 {
  width: 400px;
}
.dialog-footer {
  text-align: right;
}
</style>
