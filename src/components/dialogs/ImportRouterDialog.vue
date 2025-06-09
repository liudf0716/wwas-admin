<template>
  <el-dialog title="导入路由" :visible.sync="isVisible" @close="handleDialogClose" class="digcont">
    <el-tabs v-model="activeTab" type="card" @tab-click="handleTabClick">
      <el-tab-pane label="文件上传" name="1">
        <div>
          <h4>下载示范模板</h4>
          <p class="mb30">
            路由导入模板.xls
            <a href="http://cloud.kunteng.org/yunac/static/tmp/routers.xls" target="_blank">
              <el-button class="btn1" size="small" type="primary">下载</el-button>
            </a>
          </p>
        </div>
        <div>
          <h4>上传</h4>
          <el-form :model="fileForm" ref="uploadFormRef">
            <el-form-item label="">
              <el-upload
                class="upload-demo"
                ref="uploadComponentRef"
                name="file_name"
                :action="uploadUrl"
                with-credentials="true"
                :data="fileForm"
                :before-upload="handleBeforeUpload"
                :on-change="handleFileChange"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                :file-list="fileList"
                :auto-upload="false"
              >
                <el-button slot="trigger" size="small" type="primary">选取文件</el-button>
              </el-upload>
            </el-form-item>
          </el-form>
        </div>
        <div class="mt30 dialog-footer">
          <el-button @click="handleDialogClose">取 消</el-button>
          <el-button type="primary" @click="submitUpload" :loading="uploading">保 存</el-button>
        </div>
      </el-tab-pane>
      <el-tab-pane label="手动导入" name="2">
        <el-form :model="manualForm" ref="manualFormRef" :rules="manualRules">
          <el-form-item label="设备ID" prop="device_id" :label-width="formLabelWidth">
            <el-input v-model="manualForm.device_id" class="diainp"></el-input>
          </el-form-item>
          <el-form-item label="启用认证网关设备" prop="route_mac" :label-width="formLabelWidth">
            <el-input
              type="textarea"
              :rows="2"
              placeholder="请输入网关ID，如果要输入多个，每行输入一个；网关ID一般为MAC地址，格式为12位字母或数字组合，不区分大小写"
              v-model="manualForm.route_mac"
            ></el-input>
          </el-form-item>
          <el-form-item label="启用单次认证网关设备" prop="route_mac_once_auth" :label-width="formLabelWidth">
            <el-input
              type="textarea"
              :rows="2"
              placeholder="请输入网关ID，如果要输入多个，每行输入一个；网关ID一般为MAC地址，格式为12位字母或数字组合，不区分大小写"
              v-model="manualForm.route_mac_once_auth"
            ></el-input>
          </el-form-item>
          <el-form-item label="单次认证免认证时长" prop="next_auth_time" :label-width="formLabelWidth">
            <el-input
              v-model="manualForm.next_auth_time"
              placeholder="请输入免认证时长"
              class="diainp"
            ></el-input>
          </el-form-item>
        </el-form>
        <div class="mt30 dialog-footer">
          <el-button @click="handleDialogClose">取 消</el-button>
          <el-button type="primary" @click="saveManualImport" :loading="manualSaving">保 存</el-button>
        </div>
      </el-tab-pane>
    </el-tabs>
  </el-dialog>
</template>

<script>
import global_ from 'components/common/Global';

export default {
  name: 'ImportRouterDialog',
  props: {
    visible: { type: Boolean, default: false },
    formLabelWidth: { type: String, default: '120px' },
    targetAccount: { type: String, required: true },
    uploadUrlProp: { type: String, required: true }
  },
  data() {
    const validateMacInForm = (rule, value, callback) => {
      if (!value) {
          callback();
          return;
      }
      const regMac1 = /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
      const regMac2 = /^[A-Fa-f\d]{12}$/;
      const macs = this.splitStringByCommaOrNewline(value);
      for (const mac of macs) {
        if (mac && !regMac1.test(mac) && !regMac2.test(mac)) {
          return callback(new Error('MAC输入有误，请检查格式和分隔符'));
        }
      }
      callback();
    };

    return {
      activeTab: '1',
      fileList: [],
      fileForm: {
        user_name: this.targetAccount,
      },
      uploading: false,
      manualForm: {
        device_id: '',
        route_mac: '',
        route_mac_once_auth: '',
        next_auth_time: '',
      },
      manualRules: {
        route_mac: [
          { validator: validateMacInForm, trigger: 'blur' }
        ],
        route_mac_once_auth: [
          { validator: validateMacInForm, trigger: 'blur' }
        ],
      },
      manualSaving: false,
      uploadUrl: this.uploadUrlProp || (global_.baseUrl + '/device/import/excel'),
    };
  },
  computed: {
    isVisible: {
      get() { return this.visible; },
      set(value) { this.$emit('update:visible', value); },
    },
  },
  watch: {
    visible(newVal) {
      if (newVal) {
        this.resetForms();
        this.fileForm.user_name = this.targetAccount;
      }
    },
    targetAccount(newVal) {
        this.fileForm.user_name = newVal;
    },
    uploadUrlProp(newVal){
        this.uploadUrl = newVal;
    }
  },
  methods: {
    resetForms() {
      this.activeTab = '1';
      this.fileList = [];
      if (this.$refs.uploadComponentRef) {
        this.$refs.uploadComponentRef.clearFiles();
      }
      this.manualForm = {
        device_id: '',
        route_mac: '',
        route_mac_once_auth: '',
        next_auth_time: '',
      };
      if (this.$refs.manualFormRef) {
        this.$refs.manualFormRef.resetFields();
      }
      this.uploading = false;
      this.manualSaving = false;
    },
    handleDialogClose() {
      this.isVisible = false;
      this.$emit('close');
    },
    handleTabClick(tab) {
      // Tab click logic, if any needed beyond changing activeTab
    },
    submitUpload() {
      if (this.fileList.length === 0) {
        this.$message.warning('请先选取文件');
        return;
      }
      this.uploading = true;
      this.$refs.uploadComponentRef.submit();
    },
    handleBeforeUpload(file) {
      const testmsg = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase();
      const validExtensions = ['xls', 'xlsx'];
      const isValidExt = validExtensions.includes(testmsg);
      const isLt10M = file.size / 1024 / 1024 < 10;

      if (!isValidExt) {
        this.$message.error('上传模板只能是 xls 或 xlsx 格式!');
        return false;
      }
      if (!isLt10M) {
        this.$message.error('上传模板大小不能超过 10MB!');
        return false;
      }
      return true;
    },
    handleFileChange(file, fileList) {
        this.fileList = fileList.slice(-1);
    },
    handleUploadSuccess(response, file, fileList) {
      this.uploading = false;
      this.fileList = fileList;
      this.$emit('upload-success', response);
    },
    handleUploadError(err, file, fileList) {
      this.uploading = false;
      this.$emit('upload-error', err);
    },
    saveManualImport() {
      this.$refs.manualFormRef.validate((valid) => {
        if (valid) {
          if (!this.manualForm.route_mac && !this.manualForm.route_mac_once_auth) {
              this.$message.warning('至少需要输入一种认证网关设备MAC');
              return;
          }
          this.manualSaving = true;
          const dataToSave = {
            user_name: this.targetAccount,
            ...this.manualForm,
          };
          this.$emit('manual-save', dataToSave);
        } else {
          // console.log('Validation failed for Manual Router Import'); // Removed
          return false;
        }
      });
    },
    onSaveManualSuccess() {
        this.manualSaving = false;
        this.handleDialogClose();
    },
    onSaveManualError() {
        this.manualSaving = false;
    },
    onUploadFinished() {
        this.uploading = false;
        this.handleDialogClose();
    },
    splitStringByCommaOrNewline(str) {
        if (!str) return [];
        return str.split(/[\n,]/g).map(s => s.trim()).filter(s => s !== "");
    },
  },
};
</script>

<style scoped>
.digcont { }
.diainp { width: 217px; }
.mb30 { margin-bottom: 30px; }
.mt30 { margin-top: 30px; }
.upload-demo { }
.dialog-footer { text-align: right; }
.btn1{margin-bottom:5px;margin-top:5px;}
</style>
