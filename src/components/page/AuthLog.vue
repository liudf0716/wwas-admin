<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-help"></i> 日志管理</el-breadcrumb-item>
        <el-breadcrumb-item>认证日志</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div>
      <el-form :inline="true">
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="yyyy-MM-dd"
            value-format="timestamp"
            @change="handleDateChange"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入认证帐号" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe resizable style="width: 100%" ref="multipleTable">
      <el-table-column type="index"></el-table-column>
      <el-table-column prop="authType" label="认证类型"></el-table-column>
      <el-table-column prop="authAccount" label="认证帐号" min-width="110"></el-table-column>
      <el-table-column prop="placeCode" label="上网服务场所编码"> </el-table-column>
      <el-table-column prop="loginTime" label="上线时间"></el-table-column>
      <el-table-column prop="logoutTime" label="下线时间"></el-table-column>
      <el-table-column prop="innerIP" label="内网IP"></el-table-column>
      <el-table-column prop="srcIP" label="源外网IPv4"></el-table-column>
      <el-table-column prop="srcPortStart" label="源起始端口号"></el-table-column>
      <el-table-column prop="srcPortEnd" label="源结束端口号"></el-table-column>
      <el-table-column prop="terminalMac" label="终端MAC地址"></el-table-column>
      <el-table-column prop="apID" label="AP编号"></el-table-column>
      <el-table-column prop="apMac" label="APMAC"></el-table-column>
      <el-table-column prop="apLongitude" label="经度"></el-table-column>
      <el-table-column prop="apLatitude" label="纬度"></el-table-column>
      <el-table-column prop="signalStrength" label="场强"></el-table-column>
      <el-table-column prop="sessionID" label="会话ID"> </el-table-column>
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
      uploading: false,
      dateRange: []
    };
  },

  created: function () {
    this.getDataList();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
    async getDataList() {
      this.listData = [];
      try {
        const payload = {
          dateRange: this.dateRange,
          searchQuery: this.searchQuery,
          page: this.currentPage,
          size: 10
        };
        const res = await this.$axios.post(baseUrl + '/log/auth', payload);
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
    handleDateChange: function (val) {
      if (val && val.length === 2) {
        this.dateRange = [val[0].getTime(), val[1].getTime()];
        this.getDataList(); // Fetch data for the new date range
      } else {
        this.dateRange = []; // Reset if no valid date range
      }
    },
    handleCurrentChange: function (val) {
      this.currentPage = val;
      this.getDataList(); // Fetch data for the new page
    },

    search: function () {
      this.current_page = 1;
      // Pass an empty string for the URL, as _fetchDeviceData appends '/device/list'
      this.getDataList();
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
