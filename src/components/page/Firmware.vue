<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 固件管理</el-breadcrumb-item>
        <el-breadcrumb-item>固件列表</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入设备型号"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>

      <el-button type="primary" @click="handleDialogVisible">上传固件</el-button>
    </div>

    <el-dialog title="上传固件" :visible.sync="showUploadDialogVisible" size="tiny" @close="handleDialogClose">
      <el-form ref="uploadForm" :model="uploadForm" label-width="120px">
        <el-form-item label="设备型号">
          <el-input v-model="uploadForm.deviceModel" placeholder="请输入设备类型" style="width: 80%"></el-input>
        </el-form-item>
        <el-form-item label="固件版本">
          <el-input v-model="uploadForm.version" placeholder="请输入版本号" style="width: 80%"></el-input>
        </el-form-item>
        <el-form-item label="固件说明">
          <el-input type="textarea" autosize v-model="uploadForm.releaseNotes" placeholder="请输入固件说明" style="width: 80%"></el-input>
        </el-form-item>
        <el-form-item label="上传固件">
          <el-upload action="/api/firmware/upload" :multiple="false" :limit="1" :data="uploadForm" :on-success="handleUploadSuccess" :auto-upload="false" ref="fileUpload">
            <el-button type="primary">选择文件</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="handleDialogClose">取消</el-button>
        <el-button type="primary" @click="submitUpload">上传</el-button>
      </span>
    </el-dialog>
    <el-table :data="listData" stripe resizable style="width: 100%" ref="multipleTable" v-loading="loading">
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
      loading: false,
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
      }
    };
  },

  created: function () {
    this.getFirmwares();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
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
    handleUploadError() {},
    submitUpload() {
      if (!this.uploadForm.deviceModel || !this.uploadForm.version) {
        this.$message({ message: '请填写所有必填项', type: 'warning' });
        return;
      }
      this.$refs.fileUpload.submit();
    },
    handleUploadSuccess(response, file, fileList) {
      if (response.ret_code === 0) {
        this.$message({ message: '固件上传成功', type: 'success' });
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
