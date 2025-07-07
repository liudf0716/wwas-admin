<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-help"></i> 固件管理</el-breadcrumb-item>
        <el-breadcrumb-item>固件列表</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入设备型号" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>

      <el-button type="primary" @click="handleDialogVisible">上传固件</el-button>
    </div>

    <el-dialog title="上传固件" :visible.sync="showUploadDialogVisible" size="tiny" @close="handleDialogClose" width="700px">
      <el-alert
        title="设备型号和版本号从固件名称自动解析(openwrt固件名称格式)"
        type="info"
        :closable="false"
        show-icon
        style="margin-bottom: 10px"
        description="openwrt-发行版-(r固件版本)-架构-方案-厂商_(设备型号)-squashfs-sysupgrade.bin"
      >
      </el-alert>
      <el-form ref="uploadForm" :model="uploadForm" label-width="120px">
        <el-form-item label="上传固件">
          <el-upload
            action="/api/firmware/upload"
            :multiple="false"
            :limit="1"
            :data="uploadForm"
            :on-success="handleUploadSuccess"
            :on-change="handleFileChange"
            :auto-upload="false"
            :on-exceed="handleBeforExced"
            ref="fileUpload"
          >
            <el-button type="primary" size="mini">选择文件</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="设备型号">
          <el-input v-model="uploadForm.deviceModel" style="width: 80%"></el-input>
        </el-form-item>
        <el-form-item label="固件版本">
          <el-input v-model="uploadForm.version" style="width: 80%"></el-input>
        </el-form-item>
        <el-form-item label="固件说明">
          <el-input type="textarea" autosize v-model="uploadForm.releaseNotes" placeholder="请输入固件说明" style="width: 80%" :autosize="{ minRows: 2 }"></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="handleDialogClose">取消</el-button>
        <el-button type="primary" @click="submitUpload" :loading="uploading">上传</el-button>
      </span>
    </el-dialog>
    <el-table :data="listData" stripe resizable style="width: 100%" ref="multipleTable">
      <el-table-column type="index"></el-table-column>
      <el-table-column prop="deviceModel" label="设备型号" width="100"></el-table-column>
      <el-table-column prop="version" label="固件版本" width="100"></el-table-column>
      <el-table-column prop="name" label="固件名称"></el-table-column>
      <el-table-column prop="fileSize" label="固件大小" width="100">
        <template slot-scope="scope">
          <span>{{ bytesLabel(scope.row.fileSize / 1024) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="releaseNotes" label="固件说明" width="300" show-overflow-tooltip> </el-table-column>
      <el-table-column prop="lastTime" label="发布时间" width="190">
        <template slot-scope="scope">
          <span>{{ dateForm(scope.row.releaseDate) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template slot-scope="scope">
          <el-link type="primary" :href="'/' + scope.row.filePath" style="margin-right: 10px">下载</el-link>
          <el-button type="text" style="color: red" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { timeStamp, dateForm, bytesLabel } from 'components/common/Helpers.js';
import { baseUrl } from 'components/common/Global';

export default {
  data: function () {
    return {
      activeFilterTab: 'online',
      searchQuery: '',
      pageTotal: 0,
      listData: [],
      currentPage: 1,
      showDeviceDetailDialog: false,
      selectedDevice: [],
      selectedGwSettings: [],
      showUploadDialogVisible: false,
      uploadForm: {
        deviceModel: '',
        version: '',
        releaseNotes: ''
      },
      uploading: false
    };
  },

  created: function () {
    this.getFirmwares();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
    handleBeforExced() {
      this.$message.warning('请删除已选择的文件');
    },
    handleFileChange(file, fileList) {
      this.firmwareFile = file.raw;
      const fileName = file.name;

      // 提取版本号
      const versionMatch = fileName.match(/r\d+(?=-)/);
      this.uploadForm.version = versionMatch ? versionMatch[0] : '';

      // 提取设备型号
      const modelMatch = fileName.match(/_([^-]+)/);
      this.uploadForm.deviceModel = modelMatch ? modelMatch[1] : '';
    },
    handleDialogClose() {
      this.showUploadDialogVisible = false;
      this.uploadForm = {
        deviceModel: '',
        version: '',
        releaseNotes: ''
      };
      this.$nextTick(() => {
        if (this.$refs.fileUpload) {
          this.$refs.fileUpload.clearFiles();
        }
      });
    },
    handleDialogVisible() {
      this.showUploadDialogVisible = true;
      this.uploadForm = {
        deviceModel: '',
        version: '',
        releaseNotes: ''
      };
    },
    handleUploadError() {
      this.uploading = false;
    },
    submitUpload() {
      if (!this.uploadForm.deviceModel || !this.uploadForm.version) {
        this.$message({ message: '请填写所有必填项', type: 'warning' });
        return;
      }

      this.$refs.fileUpload.submit();
      this.uploading = true;
    },
    handleUploadSuccess(response, file, fileList) {
      if (response.ret_code === 0) {
        this.$message({ message: '固件上传成功', type: 'success' });
        this.uploading = false;
        this.handleDialogClose(); // 关闭对话框并清理状态
        this.getFirmwares(); // 刷新固件列表
      } else {
        this.$message({ message: response.extra || '上传失败', type: 'error' });
      }
    },
    async getFirmwares() {
      try {
        const res = await this.$axios.get(baseUrl + '/firmware/query?size=10&page=' + this.currentPage);
        if (res.data.ret_code === 1001) {
          this._handleApiError(res.data.extra, true);
        } else if (res.data.ret_code === 0) {
          this.listData = res.data.extra.data;
          this.pageTotal = res.data.extra.total;
        }
      } catch (error) {
        this._handleApiError('Network error or request failed while fetching user info: ' + error.message, false);
      }
    },

    handleDelete(id) {
      this.$confirm('确定删除该固件吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
        .then(() => {
          this.$axios
            .delete(baseUrl + '/firmware/delete/' + id)
            .then(res => {
              if (res.data.ret_code === 0) {
                this.$message({ message: '删除成功', type: 'success' });
                this.getFirmwares(); // Refresh the list after deletion
              } else {
                this.$message({ message: res.data.extra, type: 'warning' });
              }
            })
            .catch(error => {
              this._handleApiError('Network error or request failed while deleting firmware: ' + error.message, false);
            });
        })
        .catch(() => {});
    },

    handleCurrentChange: function (val) {
      this.currentPage = val;
      this.getFirmwares(); // Fetch data for the new page
    },

    search: function () {
      this.current_page = 1;
      // Pass an empty string for the URL, as _fetchDeviceData appends '/device/list'
      this.getFirmwares();
    },

    _handleApiError(errorMessage, isAuthError = false) {
      this.$message({ message: errorMessage, type: 'warning' });
      if (isAuthError) {
        setTimeout(() => {
          this.$router.replace('login');
        }, 2000);
      }
    }
  }
};
</script>
<style>
  .rad-group {
    margin-bottom: 20px;
  }

  .handle-input {
    width: 300px;
    display: inline-block;
  }
  .handle-box2 {
    display: inline-block;
    float: right;
  }
  .orange {
    color: #eb9e05;
    background: none;
  }
  .btn-search {
    position: absolute;
  }

  .dialog-content {
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .dialog-section {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .dialog-title {
    font-weight: bold;
    font-size: 16px;
    margin-bottom: 10px;
  }

  .dialog-footer {
    text-align: right;
  }
</style>
