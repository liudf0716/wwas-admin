<template>
  <div class="table">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-bank-card"></i> 设备管理</el-breadcrumb-item>
        <el-breadcrumb-item>设备状态</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group">
      <el-radio-group v-model="activeFilterTab" @change="changeTab" size="small">
        <el-radio-button label="online">在线</el-radio-button>
        <el-radio-button label="offline">离线</el-radio-button>
        <el-radio-button label="all">全部</el-radio-button>
      </el-radio-group>
      <el-form :inline="true" class="handle-box2">
        <el-form-item label="">
          <el-input v-model="searchQuery" placeholder="请输入设备ID" size="small"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search" size="small">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-table :data="listData" stripe style="width: 100%" ref="multipleTable" v-loading="loading">
      <el-table-column prop="deviceID" label="设备ID" width="120" show-overflow-tooltip></el-table-column>
      <!-- <el-table-column prop="deviceCode" label="设备编码" min-width="100"></el-table-column> -->
      <el-table-column prop="name" label="设备名称" width="120" show-overflow-tooltip></el-table-column>
      <el-table-column prop="macAddress" label="MAC地址" width="150" show-overflow-tooltip></el-table-column>
      <el-table-column prop="locationID" label="场所编码" width="150" show-overflow-tooltip></el-table-column>

     
      <el-table-column prop="onlineClients" label="在线客户数" width="100" align="center"></el-table-column>
      <el-table-column label="位置坐标" width="180" show-overflow-tooltip>
        <template slot-scope="scope"> {{ scope.row.longitude }},{{ scope.row.latitude }} </template>
      </el-table-column>

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
      <el-table-column label="操作" width="250">
        <template slot-scope="scope">
          <el-button 
        type="text" 
        size="small"
        @click="showDetail(scope.row)"
        :disabled="scope.row.deviceStatus !== '1'"
        :class="{ 'disabled-button': scope.row.deviceStatus !== '1' }">
        详情
          </el-button>
          <el-button 
        type="text" 
        size="small"
        @click="handleEdit(scope.row)"
        :disabled="scope.row.deviceStatus !== '1'"
        :class="{ 'disabled-button': scope.row.deviceStatus !== '1' }">
        编辑
          </el-button>
          <el-dropdown 
            @command="handleCommand" 
            trigger="click"
            :disabled="scope.row.deviceStatus !== '1'"
            :class="{ 'disabled-dropdown': scope.row.deviceStatus !== '1' }">
            <el-button 
              type="text" 
              size="small"
              :disabled="scope.row.deviceStatus !== '1'"
              :class="{ 'disabled-button': scope.row.deviceStatus !== '1' }">
              更多<i class="el-icon-arrow-down el-icon--right"></i>
            </el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item 
                :command="{action: 'reboot', row: scope.row}"
                :disabled="rebootingDevices.has(scope.row.deviceID)"
                :class="{ 'rebooting-item': rebootingDevices.has(scope.row.deviceID) }">
                {{ rebootingDevices.has(scope.row.deviceID) ? '重启中...' : '设备重启' }}
              </el-dropdown-item>
              <el-dropdown-item :command="{action: 'wireless', row: scope.row}">无线设置</el-dropdown-item>
              <el-dropdown-item :command="{action: 'domains', row: scope.row}">域名白名单</el-dropdown-item>
              <el-dropdown-item :command="{action: 'wildcardDomains', row: scope.row}">泛域名白名单</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
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

    <el-dialog title="无线设置" :visible.sync="showWirelessDialog" width="600px">
      <div v-if="wirelessLoading">正在加载...</div>
      <div v-else>
        <el-form label-width="120px">
          <div v-for="(radio, index) in wifiInfo" :key="index">
            <h4>{{ radio.name }}</h4>
            <el-form-item label="SSID">
              <el-input v-model="radio.ssid"></el-input>
            </el-form-item>
            <el-form-item label="Mesh ID">
              <el-input v-model="radio.mesh_id"></el-input>
            </el-form-item>
          </div>
        </el-form>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showWirelessDialog = false">取消</el-button>
        <el-button type="primary" @click="saveWifiSettings">保存</el-button>
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
      activeFilterTab: 'online',
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
      rebootingDevices: new Set(), // 追踪正在重启的设备ID
      showWirelessDialog: false,
      wirelessLoading: false,
      wifiInfo: [],
      currentDevice: null,

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
    this.getData('/online');
  },

  methods: {
    timeStamp: timeStamp,
    dateForm: dateForm,
    bytesLabel: bytesLabel,
    cpuLabel: cpuLabel,
    rebootDevice: async function(row) {
      if (row.deviceStatus !== '1') {
        this.$message({
          message: '设备离线时无法重启',
          type: 'warning'
        });
        return;
      }

      // 检查设备是否正在重启中
      if (this.rebootingDevices.has(row.deviceID)) {
        this.$message({
          message: '设备正在重启中，请稍后再试',
          type: 'warning'
        });
        return;
      }

      try {
        // 添加到重启中设备列表
        this.rebootingDevices.add(row.deviceID);
        
        const res = await this.$axios.post(baseUrl + '/device/reboot', { device_id: row.deviceID });
        if (res.data.success) {
          this.$message({ message: '重启命令已发送，10秒后可再次重启', type: 'success' });
          
          // 10秒后移除禁用状态
          setTimeout(() => {
            this.rebootingDevices.delete(row.deviceID);
          }, 10000);
        } else {
          // 如果重启失败，立即移除禁用状态
          this.rebootingDevices.delete(row.deviceID);
          this._handleApiError(res.data.error || '重启失败');
        }
      } catch (error) {
        // 如果请求失败，立即移除禁用状态
        this.rebootingDevices.delete(row.deviceID);
        this._handleApiError('网络错误或请求失败: ' + error.message);
      }
    },
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
      // 检查设备是否在线
      if (row.deviceStatus !== '1') {
        this.$message({
          message: '设备离线时无法编辑，请等待设备上线后再试',
          type: 'warning'
        });
        return;
      }
      
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
      // 检查设备是否在线
      if (row.deviceStatus !== '1') {
        this.$message({
          message: '设备离线时无法查看详情，请等待设备上线后再试',
          type: 'warning'
        });
        return;
      }

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

      // 调试信息：打印原始数据结构
      console.log('gwSettings原始数据:', row.gwSettings);
      console.log('gwSettings类型:', Array.isArray(row.gwSettings) ? 'Array' : typeof row.gwSettings);
      console.log('gwSettings长度:', row.gwSettings ? row.gwSettings.length : 'undefined');

      // 修复：确保gwSettings存在且为数组，并使用正确的遍历方式
      if (row.gwSettings && Array.isArray(row.gwSettings)) {
        for (let i = 0; i < row.gwSettings.length; i++) {
          const gwSetting = row.gwSettings[i];
          if (gwSetting && (gwSetting.gwID || gwSetting.gwChannel)) { // 只添加有效数据
            this.selectedGwSettings.push({
              gwID: gwSetting.gwID,
              gwChannel: gwSetting.gwChannel,
              authMode: gwSetting.authMode
            });
          }
        }
      } else if (row.gwSettings && typeof row.gwSettings === 'object') {
        // 如果是对象而不是数组，使用for...in但过滤无效数据
        for (let i in row.gwSettings) {
          if (row.gwSettings.hasOwnProperty(i)) {
            const gwSetting = row.gwSettings[i];
            if (gwSetting && (gwSetting.gwID || gwSetting.gwChannel)) { // 只添加有效数据
              this.selectedGwSettings.push({
                gwID: gwSetting.gwID,
                gwChannel: gwSetting.gwChannel,
                authMode: gwSetting.authMode
              });
            }
          }
        }
      }

      console.log('处理后的selectedGwSettings:', this.selectedGwSettings);

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

    handleCommand(command) {
      const { action, row } = command;
      
      if (row.deviceStatus !== '1') {
        this.$message({
          message: '设备离线时无法执行操作，请等待设备上线后再试',
          type: 'warning'
        });
        return;
      }

      switch (action) {
        case 'reboot':
          this.rebootDevice(row);
          break;
        case 'wireless':
          this.handleWirelessSettings(row);
          break;
        case 'domains':
          this.handleDomainWhitelist(row);
          break;
        case 'wildcardDomains':
          this.handleWildcardDomainWhitelist(row);
          break;
        default:
          console.log('Unknown command:', action);
      }
    },

    async handleWirelessSettings(row) {
      this.currentDevice = row;
      this.showWirelessDialog = true;
      this.wirelessLoading = true;
      try {
        const res = await this.$axios.post(baseUrl + '/device/getWifiInfo', { device_id: row.deviceID });
        if (res.data.data) {
          this.wifiInfo = Object.entries(res.data.data).map(([name, values]) => ({
            name,
            ...values
          }));
        } else {
          this._handleApiError(res.data.error || '获取无线信息失败');
        }
      } catch (error) {
        this._handleApiError('网络错误或请求失败: ' + error.message);
      } finally {
        this.wirelessLoading = false;
      }
    },

    async saveWifiSettings() {
      const data = this.wifiInfo.reduce((acc, radio) => {
        acc[radio.name] = {
          ssid: radio.ssid,
          mesh_id: radio.mesh_id
        };
        return acc;
      }, {});

      try {
        const res = await this.$axios.post(baseUrl + '/device/setWifiInfo', { device_id: this.currentDevice.deviceID, data });
        if (res.data.data.status === 'success') {
          this.$message({ message: '无线设置已保存', type: 'success' });
          this.showWirelessDialog = false;
        } else {
          this._handleApiError(res.data.error || '保存无线信息失败');
        }
      } catch (error) {
        this._handleApiError('网络错误或请求失败: ' + error.message);
      }
    },

    handleDomainWhitelist(row) {
      this.$message({
        message: '域名白名单功能开发中...',
        type: 'info'
      });
      // TODO: 实现域名白名单功能
      // 可以打开一个对话框来管理域名白名单
    },

    handleWildcardDomainWhitelist(row) {
      this.$message({
        message: '泛域名白名单功能开发中...',
        type: 'info'
      });
      // TODO: 实现泛域名白名单功能
      // 可以打开一个对话框来管理泛域名白名单
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
    float: right;
  }
  .orange {
    color: #eb9e05;
    background: none;
  }
  .btn-search {
    position: absolute;
  }

  /* 禁用按钮样式 */
  .disabled-button {
    color: #c0c4cc !important;
    cursor: not-allowed !important;
    opacity: 0.6 !important;
  }
  
  .disabled-button:hover {
    color: #c0c4cc !important;
    text-decoration: none !important;
  }

  /* 禁用下拉菜单样式 */
  .disabled-dropdown {
    opacity: 0.6 !important;
  }
  
  .disabled-dropdown .el-dropdown__caret-button {
    cursor: not-allowed !important;
  }

  /* 重启中状态样式 */
  .rebooting-item {
    color: #909399 !important;
    cursor: not-allowed !important;
  }
  
  .rebooting-item:hover {
    background-color: transparent !important;
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
