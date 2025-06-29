<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 设备管理</el-breadcrumb-item>
        <el-breadcrumb-item>认证用户</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="search_word" placeholder="请输入设备ID"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="queryClientsOfDevice">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" border style="width: 100%" ref="multipleTable" v-loading="loading">
      <el-table-column prop="deviceID" label="设备ID"></el-table-column>
      <el-table-column prop="gwID" label="认证网关ID"></el-table-column>
      <el-table-column prop="gwChannel" label="渠道"></el-table-column>
      <el-table-column prop="mac" label="用户MAC"></el-table-column>
      <el-table-column prop="ip" label="用户IP"></el-table-column>
      <el-table-column prop="lastTime" label="最后在线时间">
        <template slot-scope="scope">
          {{ dateForm(scope.row.lastTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button type="text" @click="showDetail(scope.row)">详情</el-button>
          <el-button class="btn1" size="small" type="danger" :disabled="!scope.row.isOnline" @click="kickOffline(scope.row)"> 强制下线 </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :visible.sync="showClientDetailDialog" title="客户端详情" width="30%">
      <el-form :model="detailForm">
        <el-table :data="selectedClient" border>
          <el-table-column prop="key" label="描述"></el-table-column>
          <el-table-column prop="value" label="值"></el-table-column>
        </el-table>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button type="primary" @click="showClientDetailDialog = false">确定</el-button>
      </span>
    </el-dialog>

    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { baseUrl } from 'components/common/Global';
import { timeStamp, dateForm, bandwidthLabel, search } from 'components/common/Helpers.js';

const API_SUCCESS_CODE = 0;
const API_SESSION_EXPIRED_CODE = 1001;
const USER_TYPE_ADMIN = 0;
const USER_TYPE_CHANNEL_ADMIN = 1;

export default {
  data: function () {
    return {
      radio3: 'online',
      search_word: '',
      loading: false,
      pageTotal: 0,
      listData: [],
      selectedClient: [],
      currentPage: 1,
      curUser: '',
      detailForm: {},
      formLabelWidth: '120px',
      fullscreenLoading: false,
      showClientDetailDialog: false
    };
  },

  created: function () {
    this.getUser();
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bandwidthLabel: bandwidthLabel,
    search: search,

    _apiRequest: function (urlEndpoint, params, successCallback) {
      // Return the promise for further chaining like .finally()
      return this.$axios
        .post(baseUrl + urlEndpoint, params)
        .then(res => {
          if (res.data.ret_code == API_SESSION_EXPIRED_CODE) {
            this.$message({ message: res.data.extra, type: 'warning' });
            setTimeout(() => {
              this.$router.replace('login');
            }, 2000);
          } else if (res.data.ret_code == API_SUCCESS_CODE) {
            successCallback(res.data.extra);
          } else {
            this.$message({ message: res.data.extra, type: 'warning' });
          }
        })
        .catch(error => {
          console.error('API Request Error:', error);
          this.$message({ message: '请求失败，请检查网络或联系管理员', type: 'error' });
        });
    },

    getUser: function () {
      this._apiRequest('/admin/info', {}, data => {
        const user = data;
        this.curUser = user.userType;
        if (this.curUser === USER_TYPE_CHANNEL_ADMIN || this.curUser === USER_TYPE_ADMIN) {
          this.getData();
        } else {
          this.$message({ message: '用户类型错误', type: 'warning' });
        }
      });
    },

    getData: function () {
      this.loading = true;
      let params = {};
      // if (this.curUser === USER_TYPE_CHANNEL_ADMIN) {
      if (this.curUser) {
        params['gwChannel'] = localStorage.getItem('ms_username');
      }
      this._apiRequest('/client/list', params, data => {
        this.pageTotal = data.clients.length || this.pageTotal;
        console.log(data.clients);
        this.listData = data.clients;
      })
        // Ensure loading is false regardless of _apiRequest outcome for getData
        .finally(() => {
          this.loading = false;
        });
    },

    showDetail: function (row) {
      this.showClientDetailDialog = true;
      this.selectedClient = [
        { key: '用户MAC', value: row.mac },
        { key: '用户IP', value: row.ip },
        { key: '设备ID', value: row.deviceID },
        { key: '认证网关ID', value: row.gwID },
        { key: '渠道', value: row.gwChannel },
        { key: '用户名', value: row.name },
        { key: '是否有线用户', value: row.wired },
        { key: '下行流量', value: this.bandwidthLabel(row.incoming) },
        { key: '上行流量', value: this.bandwidthLabel(row.outgoing) },
        { key: '认证方式', value: row.authType },
        { key: '认证时间', value: this.dateForm(row.firstLogin) },
        { key: '在线时长', value: this.timeStamp(row.onlineTime) },
        { key: '最后在线时间', value: this.dateForm(row.lastTime) },
        { key: '认证令牌', value: row.token }
      ];
    },

    queryClientsOfDevice: function () {
      return this.search(baseUrl, '/client/list', this);
    },

    kickOffline: function (row) {
      const deviceID = row.deviceID;
      const gwId = row.gwID;
      const mac = row.mac;
      const ip = row.ip;
      this._apiRequest('/client/kickoffClient', { deviceId: deviceID, gwId: gwId, mac: mac, ip: ip }, data => {
        this.$message({ message: '用户下线成功', type: 'success' });
        this.getData();
      });
    },
    handleCurrentChange: function () {}
  }
};
</script>
<style scoped>
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
</style>
