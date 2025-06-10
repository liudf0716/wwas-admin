<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-setting"></i> 设备管理</el-breadcrumb-item>
                <el-breadcrumb-item>设备状态</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class='rad-group'>
            <el-radio-group v-model="activeFilterTab" @change="changeTab">
                <el-radio-button label="online">在线</el-radio-button>
                <el-radio-button label="offline">离线</el-radio-button>
                <el-radio-button label="all">全部</el-radio-button>
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

        <el-table :data="listData" border style="width: 100%" ref="multipleTable" v-loading="loading">
            <el-table-column prop="deviceID" label="设备ID" width="150"></el-table-column>
            <el-table-column prop="name" label="设备名称" width="200"></el-table-column>
            <el-table-column prop="awVersion" label="AW版本" width="110"></el-table-column>
            <el-table-column prop='onlineClients' label="在线客户数" width="110"></el-table-column>
            <el-table-column prop="wiredPassed" label="有线免认证" width="110">
            <template slot-scope="scope">
            <el-tag :type="scope.row.wiredPassed == '0' ? 'warning':'success'" close-transition>{{scope.row.wiredPassed == '1'?'已开启':'未开启'}}</el-tag>
            </template>
            </el-table-column>
            <el-table-column prop="wifidogUptime" label="wifidog运行时长" width="160">
            <template slot-scope="scope">
            <span>{{timeStamp(scope.row.wifidogUptime)}}</span>
            </template>
            </el-table-column>
            <el-table-column prop="lastTime" label="最近上线时间" width="190">
            <template slot-scope="scope">
            <span>{{dateForm(scope.row.lastTime)}}</span>
            </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
            <template slot-scope="scope">
            <el-button type="text" @click="showDetail(scope.row)">详情</el-button>
            </template>
            </el-table-column>
        </el-table>

        <el-dialog title="设备详情" :visible.sync="showDeviceDetailDialog" width="50%">
            <div class="dialog-content">
            <div class="dialog-section">
                <div class="dialog-title">设备详细信息</div>
                <el-table :data="selectedDevice" border style="width: 100%">
                <el-table-column prop="key" label="描述" width="200"></el-table-column>
                <el-table-column prop="value" label="值" width="200"></el-table-column>
                </el-table>
            </div>
            
            <div class="dialog-section">
                <div class="dialog-title">设备所属认证网关信息</div>
                <el-table :data="selectedGwSettings" border style="width: 100%">
                <el-table-column prop="gwID" label="网关ID" width="200"></el-table-column>
                <el-table-column prop="gwChannel" label="网关渠道" width="150"></el-table-column>
                <el-table-column prop="authMode" label="认证方式" width="150">
                    <template slot-scope="scope">
                    <span>{{ scope.row.authMode == '0' ? '免认证中' : '认证中' }}</span>
                    </template>
                </el-table-column>
                </el-table>
            </div>
            </div>
            
            <span slot="footer" class="dialog-footer">
            <el-button type="primary" @click="showDeviceDetailDialog = false">确定</el-button>
            </span>
        </el-dialog>
        <div class="pagination">
            <el-pagination
                @current-change ="handleCurrentChange"
                :current-page="currentPage"
                layout="prev, pager, next"
                :total="pageTotal">
            </el-pagination>
        </div>
    </div>
</template>

<script>
    import { timeStamp, dateForm, bytesLabel, cpuLabel } from 'components/common/Helpers.js';
    import { baseUrl } from 'components/common/Global';

    const deviceDetailMap = [
        { key: 'deviceID', label: '设备ID' },
        { key: 'name', label: '设备名称' },
        { key: 'remoteAddress', label: '设备地址' },
        { key: 'awVersion', label: 'AW版本' },
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
        data: function(){
            return {
                activeFilterTab:'online',
                searchQuery:'',
                loading:false,
                pageTotal:0,
                listData:[],
                currentPage:1,
                currentUserType:'',
                showDeviceDetailDialog: false,
                selectedDevice: [],
                selectedGwSettings: [],
            }
        },

        created: function(){
            this.getUser();
        },

        methods: {
            timeStamp: timeStamp,
            dateForm: dateForm,
            bytesLabel: bytesLabel,
            cpuLabel: cpuLabel,

            async getUser() {
                try {
                    const res = await this.$axios.post(baseUrl + '/admin/info');
                    if (res.data.ret_code === '1001') {
                        this._handleApiError(res.data.extra, true);
                    } else if (res.data.ret_code === 0) {
                        const user = res.data.extra;
                        this.currentUserType = user.userType;
                        if (this.currentUserType === '1' || this.currentUserType === '0') {
                            this.getData('/online');
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

            getData: function(url) { // Accepts a URL string
                this._fetchDeviceData(url, {});
            },

            showDetail: function(row) {
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

            changeTab: function(){
                const url = '/'+this.activeFilterTab;
                this.currentPage = 1;
                this.getData(url);
            },

            handleCurrentChange: function(val) {
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

            search: function() {
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
            }
        }
    }
</script>
<style>
.rad-group{margin-bottom:20px;}
.diainp{width:217px;}
.handle-input{  width: 300px;  display: inline-block;  }
.handle-box2{display:inline-block;float:right;}
.orange{color:#eb9e05;background:none;}
.btn-search{position:absolute;}

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
