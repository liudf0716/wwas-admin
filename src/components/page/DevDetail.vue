<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-upload"></i> 详情</el-breadcrumb-item>
        <!--<el-breadcrumb-item>执行结果</el-breadcrumb-item>-->
      </el-breadcrumb>
    </div>
    <div>
      <h4>基本信息</h4>
      <el-table :data="devMsgData" border style="width: 100%; margin: 20px 0 40px" ref="multipleTable">
        <el-table-column prop="onlineClients" label="在线用户" width="160"></el-table-column>
        <el-table-column prop="sysUptime" label="系统运行时长" width="160">
          <template slot-scope="scope">
            {{ timeStamp(scope.row.sysUptime) }}
          </template>
        </el-table-column>
        <el-table-column prop="sysMemfree" label="剩余内存">
          <template slot-scope="scope">
            {{ formatSysMemfree(scope.row.sysMemfree) }}
          </template>
        </el-table-column>
        <el-table-column prop="sysLoad" label="系统负载"></el-table-column>
        <el-table-column prop="cpuUsage" label="cpu利用率"></el-table-column>
        <el-table-column prop="aw_version" label="apfree-wifidog版本"></el-table-column>
        <el-table-column prop="fm_version" label="固件版本"></el-table-column>
        <el-table-column prop="type" label="设备类型"></el-table-column>
        <el-table-column prop="name" label="设备名称"></el-table-column>
      </el-table>
      <hr style="margin-bottom: 40px; height: 1px; border: none; border-top: 1px solid #ddd" />
      <el-table :data="gwClients" border style="width: 100%" ref="multipleTable">
        <el-table-column prop="clients.mac" label="路由MAC" width="180"></el-table-column>
        <el-table-column prop="clients.ip" label="终端IP" width="150"></el-table-column>
        <el-table-column prop="clients.authType" label="当前认证方式" width="120">
          <template slot-scope="scope">
            <el-tag :type="clientAuthTypeTag(scope.row.clients).type" close-transition>{{ clientAuthTypeTag(scope.row.clients).label }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="clients.telNumber" label="电话号码" width="150">
          <template slot-scope="scope">
            <el-tag :type="clientTelNumberTagType(scope.row.clients)" close-transition>{{ displayClientPhone(scope.row.clients) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="clients.name" label="终端名称" width="220"></el-table-column>
        <el-table-column prop="clients.incoming" label="下行流量" width="120">
          <template slot-scope="scope">
            {{ bandwidthLabel(scope.row.clients.incoming || 0) }}
          </template>
        </el-table-column>
        <el-table-column prop="clients.outgoing" label="上行流量" width="120">
          <template slot-scope="scope">
            {{ bandwidthLabel(scope.row.clients.outgoing || 0) }}
          </template>
        </el-table-column>
        <el-table-column prop="clients.onlineTime" label="在线时长" width="150">
          <template slot-scope="scope">
            {{ timeStamp(scope.row.clients.onlineTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="clients.lastTime" label="最近访问时间" width="200">
          <template slot-scope="scope">
            <el-tag :type="clientLastTimeTagType(scope.row.clients.lastTime)" close-transition>
              {{ dateForm(scope.row.clients.lastTime) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button class="btn1" type="warning" size="small" v-if="!scope.row.clients.kickoff" @click="handleCltOffline(scope.row.clients.mac)">下线</el-button>
            <el-button
              class="btn1"
              :type="!scope.row.clients.isTelBlocked ? 'danger' : 'success'"
              size="small"
              :disabled="scope.row.clients.telNumber == ''"
              @click="handleBlockClient(scope.row.clients.mac, scope.row.clients.isTelBlocked)"
              >{{ scope.row.clients.isTelBlocked ? '解除电话黑名单' : '电话黑名单' }}</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </div>
    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { baseUrl } from 'components/common/Global';
import { timeStamp, dateForm, isOffline, bandwidthLabel } from 'components/common/Helpers.js';

export default {
  data: function () {
    return {
      curGwid: '',
      loading: false,
      gwClients: [],
      devMsgData: [],
      pageTotal: 0,
      currentPage: 1
    };
  },
  computed: {
    // Computed property for sysMemfree display
    formatSysMemfree() {
      // Returns a function that takes memfree as an argument
      return memfree => {
        if (memfree === undefined || memfree === null) return 'N/A';
        return (memfree / 1024).toFixed(2) + 'M';
      };
    },
    // Computed property for client authType tag
    clientAuthTypeTag() {
      // Returns a function that takes client as an argument
      return client => {
        if (!client) return { type: 'info', label: '未知' };
        return {
          type: client.authType == 1 ? 'success' : 'info',
          label: client.authType == 1 ? '电话认证' : '其他认证'
        };
      };
    },
    // Computed property for client telNumber tag type
    clientTelNumberTagType() {
      // Returns a function that takes client as an argument
      return client => {
        if (!client) return 'info';
        return client.telNumber == '' ? 'info' : 'success';
      };
    },
    // Computed property for client lastTime tag type
    clientLastTimeTagType() {
      // Returns a function that takes lastTime as an argument
      return lastTime => {
        return this.isOffline(lastTime) ? 'warning' : 'success';
      };
    }
  },
  created: function () {
    this.getParams();
  },
  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    isOffline: isOffline,
    bandwidthLabel: bandwidthLabel,

    // Helper function for API calls
    _makeApiCall: function (url, params, successCallback, errorCallback) {
      this.loading = true;
      this.$axios
        .post(url, params)
        .then(res => {
          this.loading = false;
          if (res.data.ret_code == '1001') {
            this.$message({ message: res.data.extra, type: 'warning' });
            setTimeout(() => {
              this.$router.replace('login');
            }, 2000);
          } else if (res.data.ret_code == 0) {
            if (successCallback) {
              successCallback(res.data);
            }
          } else {
            if (errorCallback) {
              errorCallback(res.data);
            } else {
              this.$message.error(res.data.extra);
            }
          }
        })
        .catch(err => {
          this.loading = false;
          console.log(err);
          if (errorCallback) {
            errorCallback(err);
          } else {
            this.$message.error('请求失败，请稍后再试');
          }
        });
    },

    getParams: function () {
      this.curGwid = this.$route.query.gwId;
      this.getDetailData({});
      this.getDevMsg();
    },

    getDetailData: function (params) {
      params.gwId = this.curGwid;
      this._makeApiCall(baseUrl + '/client/list', params, data => {
        // this.pageTotal = data.extra.count || this.pageTotal;
        this.gwClients = data.extra.gwClients;
      });
    },

    getDevMsg: function () {
      var params = {
        filter: { gwId: this.curGwid }
      };
      if (localStorage.getItem('userType') == 1) {
        //非超级管理员
        params.filter.channelPath = localStorage.getItem('ms_username');
      }
      this._makeApiCall(baseUrl + '/device/list', params, data => {
        this.devMsgData = data.extra.query;
      });
    },

    handleCurrentChange: function (val) {
      this.currentPage = val;
      var params = {
        page_size: 10,
        current_page: this.currentPage
      };
      this.getDetailData(params);
    },

    handleCltOffline: function (mac) {
      var params = {
        filter: { gwId: this.curGwid, 'clients.mac': mac }
      };

      this.$confirm('此操作将该用户踢下线, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this._makeApiCall(baseUrl + '/client/kickoffClient', params, data => {
          this.gwClients = data.extra.gwClients;
          this.$message({
            type: 'success',
            message: '操作成功!'
          });
        });
      });
    },

    handleBlockClient: function (mac, isTelBlocked) {
      var params = {
        filter: { gwId: this.curGwid, mac: mac, isTelBlocked: isTelBlocked }
      };
      this.$confirm(isTelBlocked == false ? '此操作将禁止该电话号认证上网功能, 是否继续?' : '此操作将恢复该电话号认证上网功能，是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this._makeApiCall(baseUrl + '/client/blockClient', params, data => {
          this.gwClients = data.extra.gwClients;
          this.$message({
            type: 'success',
            message: '操作成功!'
          });
        });
      });
    },

    displayClientPhone: function (client) {
      if (client.authType != 1) return '号码不展示';
      if (client.telNumber == '') return '无电话号码';

      return client.telNumber;
    }
  }
};
</script>
<style scoped>
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
</style>
