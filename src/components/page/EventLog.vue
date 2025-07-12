<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 日志管理</el-breadcrumb-item>
        <el-breadcrumb-item>上网日志</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-form :inline="true">
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="timestamp"
            @change="handleDateChange"
            size="small"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search" size="small">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe style="width: 100%" ref="multipleTable" v-loading="loading" :max-height="tableMaxHeight">
      <el-table-column label="记录时间" width="160">
        <template slot-scope="scope">
          <span>{{ dateForm(scope.row.msg.timestamp) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="msg.session_id" label="会话ID" width="80"></el-table-column>
      <el-table-column prop="msg.protocol" label="服务类型" width="100">
        <template slot-scope="scope">
          <span>{{ portToProtocol(scope.row.msg.dst_port) }}</span>
        </template>
      </el-table-column>
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
      <el-button type="primary" size="mini" @click="exportToCSV" style="float: left; margin-right: 10px">导出</el-button>
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { timeStamp, dateForm, convertIp, portToProtocol } from 'components/common/Helpers.js';
import { baseUrl } from 'components/common/Global';

export default {
  data: function () {
    return {
      tableMaxHeight: `${window.innerHeight - 250}`,
      activeFilterTab: 'online',
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
      uploadFiles: [],
      dateRange: []
    };
  },

  created: function () {
    this.getList();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    convertIp: convertIp,
    portToProtocol: portToProtocol,
    async getList() {
      try {
        const payload = {
          dateRange: this.dateRange,
          page: this.currentPage,
          size: 10
        };
        const res = await this.$axios.post(baseUrl + '/eventLog/query', payload);
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
    async exportToCSV() {
      try {
        const payload = {
          page: 1,
          size: 1000
        };
        const res = await this.$axios.post(baseUrl + '/eventLog/query', payload);
        if (res.data.ret_code === 0) {
          const logList = res.data.extra.data.map(item => {
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

          const csvContent = [
            [
              '记录时间',
              '会话ID',
              '服务类型',
              '内网IP',
              '内网端口',
              '源外网IP',
              '源外网起始端口',
              '源外网结束端口',
              '目的公网IP',
              '目的公网端口',
              '终端MAC',
              '场所编码',
              '设备编码',
              '设备经度',
              '设备纬度'
            ],
            ...logList.map(item => [
              this.dateForm(item.msg.timestamp),
              item.msg.session_id,
              this.portToProtocol(item.msg.dst_port),
              this.convertIp(item.msg.src_ip),
              item.msg.src_port,
              item['fromhost-ip'],
              item.startPort,
              item.endPort,
              this.convertIp(item.msg.dst_ip),
              item.msg.dst_port,
              item.msg.clt_mac,
              item.msg.location_id,
              item.msg.ap_device_id,
              item.msg.ap_longitude,
              item.msg.ap_latitude
            ])
          ];

          const csvString = csvContent.map(row => row.join(',')).join('\n');
          const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
          const link = document.createElement('a');
          const url = URL.createObjectURL(blob);
          link.setAttribute('href', url);
          link.setAttribute('download', 'event_logs.csv');
          link.style.visibility = 'hidden';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        } else {
          this._handleApiError('Failed to fetch data for CSV export.', false);
        }
      } catch (error) {
        this._handleApiError('Network error or request failed while exporting CSV: ' + error.message, false);
      }
    },
    handleCurrentChange: function (val) {
      this.currentPage = val;
      this.getList();
    },
    handleDateChange: function (val) {
      this.currentPage = 1;
      if (val && val.length === 2) {
        this.dateRange = [val[0], val[1]];
        // this.getList(); // Fetch data for the new date range
      } else {
        this.dateRange = []; // Reset if no valid date range
      }
    },
    search: function () {
      this.currentPage = 1;
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
    /* margin-bottom: 20px; */
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
