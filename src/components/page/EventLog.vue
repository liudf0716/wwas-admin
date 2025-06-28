<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 日志管理</el-breadcrumb-item>
        <el-breadcrumb-item>上网日志</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group" v-show="false">
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入设备编码"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe style="width: 100%" ref="multipleTable" v-loading="loading" :max-height="tableMaxHeight">
      <el-table-column label="记录时间" width="160">
        <template slot-scope="scope">
          <span>{{ dateForm(scope.row.msg.timestamp) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="msg.sid" label="会话ID" width="80"></el-table-column>
      <el-table-column prop="msg.protocol" label="服务类型" width="100"></el-table-column>
      <el-table-column prop="msg.src_ip" label="内网IP" width="150">
        <template slot-scope="scope">
          <span>{{ convertIp(scope.row.msg.src_ip) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="msg.src_port" label="内网端口" width="100"> </el-table-column>
      <el-table-column prop="fromhost-ip" label="源外网IP" width="150"> </el-table-column>
      <el-table-column prop="startPort" label="源外网起始端口"> </el-table-column>
      <el-table-column prop="endPort" label="源外网结束端口"> </el-table-column>
      <el-table-column label="目的公网IP" width="150">
        <template slot-scope="scope">
          <span>{{ convertIp(scope.row.msg.dst_ip) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="msg.dst_port" label="目的公网端口"> </el-table-column>
      <el-table-column prop="msg.clt_mac" label="终端MAC"> </el-table-column>
      <el-table-column prop="msg.location_id" label="场所编码"> </el-table-column>
      <el-table-column prop="msg.ap_device_id" label="设备编码"> </el-table-column>
      <el-table-column prop="msg.ap_longitude" label="设备经度"> </el-table-column>
      <el-table-column prop="msg.ap_latitude" label="设备纬度"> </el-table-column>
    </el-table>

    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { timeStamp, dateForm, convertIp } from 'components/common/Helpers.js';
import { baseUrl } from 'components/common/Global';

export default {
  computed: {
    queryUrl() {
      if (this.searchQuery != '') {
        return baseUrl + '/eventLog/query?size=10&page=' + this.currentPage + '&search=' + this.searchQuery;
      }
      return baseUrl + '/eventLog/query?size=10&page=' + this.currentPage;
    }
  },
  data: function () {
    return {
      tableMaxHeight: `${window.innerHeight - 200}`,
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
      },
      uploadFiles: []
    };
  },

  created: function () {
    this.getList();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    convertIp: convertIp,
    async getList() {
      try {
        const res = await this.$axios.get(this.queryUrl);
        if (res.data.ret_code === 1001) {
          this._handleApiError(res.data.extra, true);
        } else if (res.data.ret_code === 0) {
          let logList = res.data.extra.data;
          logList = logList.map(item => {
            try {
              item.msg = JSON.parse(item.msg);
              item.startPort = 1024;
              item.endPort = 65535;
            } catch (e) {
              console.error('Failed to parse msg field:', e);
              item.msg = {}; // Fallback to an empty object if parsing fails
            }
            return item;
          });
          this.listData = logList;
          this.pageTotal = res.data.extra.total;
        }
      } catch (error) {
        this._handleApiError('Network error or request failed while fetching user info: ' + error.message, false);
      }
    },

    handleCurrentChange: function (val) {
      this.currentPage = val;
      this.getList();
    },

    search: function () {
      this.current_page = 1;
      // Pass an empty string for the URL, as _fetchDeviceData appends '/device/list'
      this.getList();
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
