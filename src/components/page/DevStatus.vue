<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-bank-card"></i> 设备管理</el-breadcrumb-item>
        <el-breadcrumb-item>设备状态</el-breadcrumb-item>
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
          <el-input v-model="searchQuery" placeholder="请输入设备ID"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe style="width: 100%" ref="multipleTable" v-loading="loading">
      <el-table-column prop="deviceID" label="设备ID" min-width="100"></el-table-column>
      <el-table-column prop="deviceCode" label="设备编码" min-width="100"></el-table-column>
      <el-table-column prop="name" label="设备名称"></el-table-column>
      <el-table-column prop="macAddress" label="MAC地址" width="150"></el-table-column>
      <el-table-column prop="locationID" label="场所编码" width="150"></el-table-column>

      <!-- <el-table-column prop="awVersion" label="AW版本"></el-table-column> -->
      <!-- <el-table-column prop="fmVersion" label="固件版本"></el-table-column> -->
      <el-table-column prop="onlineClients" label="在线客户数" align="center"></el-table-column>
      <el-table-column label="位置坐标">
        <template slot-scope="scope"> {{ scope.row.longitude }},{{ scope.row.latitude }} </template>
      </el-table-column>
      <!-- <el-table-column prop="wiredPassed" label="有线免认证">
        <template slot-scope="scope">
          <el-tag :type="scope.row.wiredPassed == '0' ? 'warning' : 'success'" close-transition>{{ scope.row.wiredPassed == '1' ? '已开启' : '未开启' }}</el-tag>
        </template>
      </el-table-column> -->
      <!-- <el-table-column prop="wifidogUptime" label="wifidog运行时长">
        <template slot-scope="scope">
          <span>{{ timeStamp(scope.row.wifidogUptime) }}</span>
        </template>
      </el-table-column> -->
      <el-table-column prop="deviceStatus" label="状态" width="90">
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
          <el-button type="text" @click="showDetail(scope.row)">详情</el-button>
          <el-button type="text" @click="handleEdit(scope.row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog title="编辑设备信息" :visible.sync="showEditDeviceDialog" width="550px" :close-on-click-modal="false">
      <el-alert title="设备基础信息修改后会同步到设备端, 请勿随意修改.(仅允许修改在线设备)" type="warning" :closable="false" show-icon> </el-alert>
      <el-form :model="editDeviceForm" label-width="120px" style="margin-top: 10px" ref="editForm" :rules="deviceRules">
        <el-form-item label="设备ID">
          {{ editDeviceForm.deviceID }}
        </el-form-item>
        <el-form-item label="设备编码" prop="deviceCode">
          <el-input v-model="editDeviceForm.deviceCode" style="width: 300px" @blur="parseDeviceCode"></el-input>
        </el-form-item>
        <el-form-item label="MAC地址" prop="macAddress">
          <el-input v-model="editDeviceForm.macAddress" style="width: 300px"></el-input>
        </el-form-item>
        <el-form-item label="场所编码" prop="locationID">
          <el-input v-model="editDeviceForm.locationID" style="width: 300px"></el-input>
        </el-form-item>
        <el-form-item label="经纬度" prop="geoPosition">
          <el-input v-model="editDeviceForm.longitude" placeholder="经度" style="width: 145px"></el-input>
          <span> - </span>
          <el-input v-model="editDeviceForm.latitude" placeholder="纬度" style="width: 145px"></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showEditDeviceDialog = false">取消</el-button>
        <el-button type="primary" @click="saveDeviceEdit">保存</el-button>
      </span>
    </el-dialog>

    <el-dialog title="设备详情" :visible.sync="showDeviceDetailDialog" width="50%">
      <el-tabs v-model="activeName">
        <el-tab-pane label="运行状态" name="first">
          <el-table :data="selectedDevice" border style="width: 100%">
            <el-table-column prop="key" label="描述"></el-table-column>
            <el-table-column prop="value" label="值"></el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="认证网关" name="second">
          <el-table :data="selectedGwSettings" border style="width: 100%">
            <el-table-column prop="gwID" label="网关ID"></el-table-column>
            <el-table-column prop="gwChannel" label="网关渠道"></el-table-column>
            <el-table-column prop="authMode" label="认证方式">
              <template slot-scope="scope">
                <span>{{ scope.row.authMode == '0' ? '免认证中' : '认证中' }}</span>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="放行规则" name="third">放行规则</el-tab-pane>
        <el-tab-pane label="域名白名单" name="fourth">域名白名单</el-tab-pane>
      </el-tabs>

      <span slot="footer" class="dialog-footer">
        <el-button type="primary" @click="showDeviceDetailDialog = false">返回</el-button>
      </span>
    </el-dialog>
    <div class="pagination">
      <el-pagination @current-change="handleCurrentChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal"> </el-pagination>
    </div>
  </div>
</template>

<script>
import { timeStamp, dateForm, bytesLabel, cpuLabel } from 'components/common/Helpers.js';
import { baseUrl } from 'components/common/Global';

const deviceDetailMap = [
  { key: 'awVersion', label: 'AW版本' },
  { key: 'fmVersion', label: '固件版本' },
  { key: 'onlineClients', label: '在线客户数' },
  { key: 'nfConntrackCount', label: '网络会话数' },
  { key: 'wiredPassed', label: '有线免认证', formatter: val => (val == '1' ? '已开启' : '未开启') },
  { key: 'wifidogUptime', label: 'wifidog运行时长', formatter: timeStamp },
  { key: 'lastTime', label: '最近上线时间', formatter: dateForm },
  { key: 'cpuUsage', label: 'CPU使用率', formatter: cpuLabel },
  { key: 'sysUptime', label: '系统运行时长', formatter: timeStamp },
  { key: 'sysMemfree', label: '系统剩余内存', formatter: bytesLabel },
  { key: 'sysLoad', label: '系统负载' }
];

export default {
  data: function () {
    return {
      activeFilterTab: 'all',
      activeName: 'first',
      searchQuery: '',
      loading: false,
      pageTotal: 0,
      listData: [],
      currentPage: 1,
      showDeviceDetailDialog: false,
      showEditDeviceDialog: false,
      selectedDevice: [],
      selectedGwSettings: [],
      editDeviceForm: {},

      deviceRules: {
        locationID: [
          { required: true, message: '请输入场所编码', trigger: 'blur' },
          { pattern: /^\d{14}$/, message: '场所编码必须是14位数字', trigger: 'blur' }
        ],
        deviceCode: [
          { required: true, message: '请输入设备编码', trigger: 'blur' },
          { pattern: /^[A-Z0-9]{9}[A-F0-9]{12}$/, message: '设备编码应为9位厂商码+12位MAC地址（共21位大写字母/数字）', trigger: 'blur' }
        ],
        macAddress: [
          { required: true, message: '请输入MAC地址', trigger: 'blur' },
          { pattern: /^([A-F0-9]{2}-){5}[A-F0-9]{2}$/, message: 'MAC地址格式应为XX-XX-XX-XX-XX-XX，均为大写', trigger: 'blur' }
        ],
        geoPosition: [
          {
            validator(rule, value, callback, source) {
              const lon = source.longitude;
              const lat = source.latitude;

              // 允许两个都为空
              if (!lon && !lat) {
                return callback();
              }

              // 只填写了一个
              if ((lon && !lat) || (!lon && lat)) {
                return callback(new Error('经纬度必须同时填写'));
              }

              // 格式判断
              const lonNum = parseFloat(lon);
              const latNum = parseFloat(lat);
              console.log('lonNum:', lonNum, 'latNum:', latNum);
              if (isNaN(lonNum) || lonNum < -180 || lonNum > 180 || lonNum == 0) {
                return callback(new Error('经度必须是 -180 到 180 之间的数字'));
              }

              if (isNaN(latNum) || latNum < -33 || latNum > 39 || latNum == 0) {
                return callback(new Error('纬度必须是 -33 到 39 之间的数字'));
              }

              callback(); // 校验通过
            },
            trigger: 'blur'
          }
        ]
      }
    };
  },

  created: function () {
    this.getData('/all');
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
    cpuLabel: cpuLabel,
    parseDeviceCode() {
      const code = this.editDeviceForm.deviceCode || '';
      if (code.length === 21) {
        const macPart = code.slice(9); // 取后12位
        const matches = macPart.match(/.{2}/g);
        const macFormatted = matches ? matches.join('-') : '';
        if (macFormatted) {
          this.editDeviceForm.macAddress = macFormatted.toUpperCase();
        }
      }
    },
    getData: function (url) {
      // Accepts a URL string
      this._fetchDeviceData(url, {});
    },

    handleEdit(row) {
      this.showEditDeviceDialog = true;
      this.editDeviceForm = {
        deviceCode: row.deviceCode,
        deviceID: row.deviceID,
        macAddress: row.macAddress,
        locationID: row.locationID,
        longitude: row.longitude,
        latitude: row.latitude
      };
    },
    async saveDeviceEdit() {
      this.$refs['editForm'].validate(async valid => {
        if (valid) {
          try {
            const res = await this.$axios.post(baseUrl + '/device/updateDeviceInfo', this.editDeviceForm);

            if (res.data.ret_code == 0) {
              this.$message({ message: '设备信息更新成功', type: 'success' });
              this.showEditDeviceDialog = false;
              this.changeTab();
            } else {
              // For other non-successful ret_codes (not 0 and not 1001)
              this._handleApiError(res.data.extra || 'Unknown error occurred', false);
            }
          } catch (error) {
            this._handleApiError('Network error or request failed: ' + error.message, false);
          }
        } else {
          console.log('error submit!!');
          return false;
        }
      });
    },
    showDetail: function (row) {
      this.selectedDevice = [];
      this.selectedGwSettings = []; // Clear previous settings

      deviceDetailMap.forEach(item => {
        if (row.hasOwnProperty(item.key)) {
          let value = row[item.key];
          if (item.formatter) {
            // Ensure formatter is called with the correct context if it's a component method
            // For helpers like timeStamp, direct call is fine.
            // If a formatter is this.someMethod, it needs this.
            // Here, timeStamp, dateForm etc. are imported helpers, not component methods.
            value = item.formatter(value);
          }
          this.selectedDevice.push({ key: item.label, value: value });
        }
      });

      for (let i in row.gwSettings) {
        this.selectedGwSettings.push({
          gwID: row.gwSettings[i].gwID,
          gwChannel: row.gwSettings[i].gwChannel,
          authMode: row.gwSettings[i].authMode
        });
      }

      this.showDeviceDetailDialog = true;
    },

    changeTab: function () {
      const url = '/' + this.activeFilterTab;
      this.currentPage = 1;
      this.getData(url);
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

    search: function () {
      if (this.searchQuery === '') {
        this.$message({ message: '输入不能为空', type: 'warning' });
        return false;
      }
      const params = { device_id: this.searchQuery };
      // Pass an empty string for the URL, as _fetchDeviceData appends '/device/list'
      this._fetchDeviceData('', params);
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
      let fullUrl = baseUrl + '/device/list' + url;
      let requestParams = { ...params };

      requestParams['gw_channel'] = localStorage.getItem('ms_username');

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
    font-size: 16px;
    margin-bottom: 10px;
  }

  .dialog-footer {
    text-align: right;
  }
</style>
