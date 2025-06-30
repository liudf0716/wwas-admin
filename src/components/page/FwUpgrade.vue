<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 设备管理</el-breadcrumb-item>
        <el-breadcrumb-item>固件升级</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-radio-group v-model="activeFilterTab" @change="changeTab">
        <el-radio-button label="all">全部</el-radio-button>
        <el-radio-button label="online">在线</el-radio-button>
        <el-radio-button label="offline">离线</el-radio-button>
      </el-radio-group>
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入设备ID" clearable></el-input>
        </el-form-item>
        <el-form-item> <el-button type="primary" @click="search">搜索</el-button> </el-form-item>
        <el-form-item>
          <el-button type="danger" @click="handleUpgrade(null)">批量升级</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe style="width: 100%" ref="multipleTable" @select-all="handleSelectAll" @select="handleCheck" @selection-change="handleSelectionChange" v-loading="loading">
      <el-table-column type="selection" width="55"> </el-table-column>
      <el-table-column prop="deviceID" label="设备ID"></el-table-column>
      <el-table-column prop="name" label="设备名称"></el-table-column>
      <el-table-column prop="type" label="设备型号"></el-table-column>
      <el-table-column prop="awVersion" label="AW版本"></el-table-column>
      <el-table-column prop="fmVersion" label="固件版本"></el-table-column>
      <el-table-column prop="wifidogUptime" label="wifidog运行时长">
        <template slot-scope="scope">
          <span>{{ timeStamp(scope.row.wifidogUptime) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="deviceStatus" label="状态">
        <template slot-scope="scope">
          <el-tag :type="scope.row.deviceStatus == '1' ? 'success' : 'danger'" close-transition>
            {{ scope.row.deviceStatus == '1' ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="lastTime" label="最近上线时间" width="190">
        <template slot-scope="scope">
          <span>{{ dateForm(scope.row.lastTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template slot-scope="scope">
          <el-button type="text" @click="handleUpgrade(scope.row)">固件升级</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog title="固件升级" :visible.sync="showSelectFmDialog" width="500px">
      <div class="dialog-content">
        <div class="dialog-section">
          <div class="dialog-title">设备ID:</div>
          <div>{{ selectedDevice.map(device => device.deviceID).join(',') }}</div>
        </div>
        <div class="dialog-section">
          <div class="dialog-title">设备型号:</div>
          <div>{{ selectedDeviceModel }}</div>
        </div>
        <div class="dialog-section">
          <div class="dialog-title">固件版本:</div>
          <el-select v-model="selectedFirmware" placeholder="请选择固件版本" value-key="id" style="width: 200px">
            <el-option v-for="firmware in filteredFirmwareList" :key="firmware.id" :label="firmware.version" :value="firmware"></el-option>
          </el-select>
        </div>
        <div class="dialog-section" v-if="selectedFirmware">
          <div class="dialog-title">固件名称:</div>
          <div>{{ selectedFirmware.name }}</div>
        </div>
      </div>
      <div class="dialog-footer">
        <el-button @click="showSelectFmDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmFirmwareSelection">确定</el-button>
      </div>
    </el-dialog>
    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { timeStamp, dateForm, bytesLabel, cpuLabel } from 'components/common/Helpers.js';
import { baseUrl } from 'components/common/Global';

export default {
  computed: {
    filteredFirmwareList() {
      // Filter firmware list based on selected device model
      return this.firmwareList.filter(fm => fm.deviceModel === this.selectedDeviceModel);
    }
  },
  data: function () {
    return {
      activeFilterTab: 'all',
      searchQuery: '',
      loading: false,
      pageTotal: 0,
      listData: [],
      firmwareList: [],
      currentPage: 1,
      currentUserType: '',
      showSelectFmDialog: false,
      selectedDevice: [],
      selectedDeviceModel: '',
      selectedFirmware: null
    };
  },

  created: function () {
    this.getUser();
    this.getFirmwares();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
    cpuLabel: cpuLabel,

    async getUser() {
      try {
        const res = await this.$axios.post(baseUrl + '/admin/info');
        if (res.data.ret_code === 1001) {
          this._handleApiError(res.data.extra, true);
        } else if (res.data.ret_code === 0) {
          const user = res.data.extra;
          this.currentUserType = user.userType;
          if (this.currentUserType === 1 || this.currentUserType === 0) {
            this.getDevices('/all');
          } else {
            // Specific error message for this case, not using _handleApiError
            this.$message({ message: '用户类型错误', type: 'warning' });
          }
        } else {
          // Handle other non-successful ret_codes from admin/info
          this._handleApiError(res.data.extra || 'Failed to get user info', false);
        }
      } catch (error) {
        this._handleApiError('Network error or request failed while fetching user info: ' + error.message, false);
      }
    },

    getDevices: function (url) {
      // Accepts a URL string
      this._fetchDeviceData(url, {});
    },
    handleUpgrade: function (device) {
      if (device) {
        this.$refs.multipleTable.clearSelection();
        this.selectedDevice = [device]; // Wrap in an array for consistency
        this.selectedDeviceModel = device.type;
      }

      if (!this.selectedDevice || this.selectedDevice.length === 0) {
        this.$message({ message: '请先选择设备', type: 'warning' });
        return;
      }

      this.showSelectFmDialog = true;
    },

    changeTab: function () {
      const url = '/' + this.activeFilterTab;
      this.currentPage = 1;
      this.getDevices(url);
    },

    handleCurrentChange: function (val) {
      this.currentPage = val;
      let urlPath = '';
      if (this.activeFilterTab === 'all') {
        urlPath = ''; // Will result in /device/list
      } else {
        urlPath = '/' + this.activeFilterTab; // Will result in /device/list/online or /device/list/offline
      }
      const params = { page_size: 10, current_page: this.currentPage };
      this._fetchDeviceData(urlPath, params);
    },

    reset: function () {
      this.activeFilterTab = 'all';
      this.searchQuery = '';
      this.changeTab();
    },
    search: function () {
      if (!this.searchQuery.length) {
        this.reset();
        return;
      }
      let params = {};
      let url = '/all';
      if (this.searchQuery.length) {
        url = '';
        params = { device_id: this.searchQuery };
      }
      // Pass an empty string for the URL, as _fetchDeviceData appends '/device/list'
      this._fetchDeviceData(url, params);
    },

    _handleApiError(errorMessage, isAuthError = false) {
      this.$message({ message: errorMessage, type: 'warning' });
      if (isAuthError) {
        setTimeout(() => {
          this.$router.replace('login');
        }, 2000);
      }
    },
    async _fetchDeviceData(url, params = {}) {
      this.loading = true;
      this.listData = [];
      let fullUrl = baseUrl + '/device/list' + url;
      let requestParams = { ...params };

      if (this.currentUserType == '1') {
        requestParams['gw_channel'] = localStorage.getItem('ms_username');
      }

      try {
        const res = await this.$axios.post(fullUrl, requestParams);
        this.loading = false;

        if (res.data.ret_code == '1001') {
          this._handleApiError(res.data.extra, true);
        } else if (res.data.ret_code == 0) {
          this.listData = res.data.extra.result;
          // Ensure pageTotal is updated correctly, especially for pagination
          if (res.data.extra.total_count !== undefined) {
            this.pageTotal = res.data.extra.total_count;
          } else {
            this.pageTotal = res.data.extra.result.length || 0;
          }
        } else {
          // For other non-successful ret_codes (not 0 and not 1001)
          this._handleApiError(res.data.extra || 'Unknown error occurred', false);
        }
      } catch (error) {
        this.loading = false;
        this._handleApiError('Network error or request failed: ' + error.message, false);
      }
    },
    async getFirmwares() {
      const res = await this.$axios.get(baseUrl + '/firmware/query?size=100&page=1');
      if (res.data.ret_code === 0) {
        this.firmwareList = res.data.extra.data;
      }
    },
    confirmFirmwareSelection() {
      if (!this.selectedFirmware) {
        this.$message({ message: '请选择固件版本', type: 'warning' });
        return;
      }
      const selectedDeviceIDs = this.selectedDevice.map(device => device.deviceID);
      if (selectedDeviceIDs.length === 0) {
        this.$message({ message: '请先选择设备', type: 'warning' });
        return;
      }

      const params = {
        deviceIds: selectedDeviceIDs,
        firmwareId: this.selectedFirmware.id,
        md5sum: this.selectedFirmware.md5sum,
        downloadUrl: this.selectedFirmware.downloadUrl,
        gw_channel: localStorage.getItem('ms_username')
      };

      this.$axios
        .post(baseUrl + '/device/sysUpgrade', params)
        .then(res => {
          if (res.data.ret_code === 0) {
            this.$message({ message: '固件升级任务已提交', type: 'success' });
            this.showSelectFmDialog = false;
            // this.getDevices('/all'); // Refresh the device list
          } else {
            this.$message({ message: res.data.extra, type: 'warning' });
          }
        })
        .catch(error => {
          this.$message({ message: '固件升级失败，请稍后再试', type: 'error' });
        });
    },
    handleSelectionChange(selection) {
      this.selectedDevice = selection;
      if (selection.length > 0) {
        this.selectedDeviceModel = selection[0].type;
      } else {
        this.selectedDeviceModel = '';
      }
    },
    handleCheck(selection, row) {
      if (this.selectedDeviceModel != '' && row.type !== this.selectedDeviceModel) {
        this.$refs.multipleTable.toggleRowSelection(row, false);
        this.$message({ message: '设备型号不一致，已取消选中', type: 'warning' });
      }
    },
    handleSelectAll(selection) {
      if (this.selectedDeviceModel !== '') {
        selection.forEach(row => {
          if (row.type !== this.selectedDeviceModel) {
            this.$refs.multipleTable.toggleRowSelection(row, false);
            this.$message({ message: '设备型号不一致，已取消选中', type: 'warning' });
          }
        });
      }
    }
  }
};
</script>
<style>
  .rad-group {
    margin-bottom: 20px;
  }
  .diainp {
    width: 217px;
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
    font-size: 14px;
    margin-bottom: 10px;
  }

  .dialog-footer {
    margin-top: 10px;
    text-align: right;
  }
</style>
