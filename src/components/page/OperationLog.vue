<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-help"></i> 日志管理</el-breadcrumb-item>
        <el-breadcrumb-item>操作日志</el-breadcrumb-item>
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
          <el-input v-model="searchQuery" placeholder="请输入用户名" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe resizable style="width: 100%" ref="multipleTable">
      <el-table-column type="index"></el-table-column>
      <el-table-column prop="user" label="用户名"></el-table-column>
      <el-table-column prop="ip" label="IP"></el-table-column>
      <el-table-column prop="method" label="请求方式">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.method === 'GET'" type="success">GET</el-tag>
          <el-tag v-else-if="scope.row.method === 'POST'" type="primary">POST</el-tag>
          <el-tag v-else-if="scope.row.method === 'PUT'" type="warning">PUT</el-tag>
          <el-tag v-else-if="scope.row.method === 'DELETE'" type="danger">DELETE</el-tag>
          <el-tag v-else type="info">{{ scope.row.method }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="path" label="访问接口"></el-table-column>
      <el-table-column prop="status" label="状态">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status >= 200 && scope.row.status < 300" type="success">{{ scope.row.status }}</el-tag>
          <el-tag v-else-if="scope.row.status >= 400 && scope.row.status < 500" type="warning">{{ scope.row.status }}</el-tag>
          <el-tag v-else-if="scope.row.status >= 500" type="danger">{{ scope.row.status }}</el-tag>
          <el-tag v-else type="info">{{ scope.row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="操作日期">
        <template slot-scope="scope">
          <span>{{ dateForm(scope.row.createdAt) }}</span>
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
        const res = await this.$axios.post(baseUrl + '/log/operation', payload);
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
