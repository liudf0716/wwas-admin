<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-setting"></i> 设备管理</el-breadcrumb-item>
                <el-breadcrumb-item>设备状态</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class='rad-group'>
            <el-radio-group v-model="radio3" @change="changeTab">
                <el-radio-button label="online">在线</el-radio-button>
                <el-radio-button label="offline">离线</el-radio-button>
                <el-radio-button label="all">全部</el-radio-button>
            </el-radio-group>
            <el-form :inline="true" class="handle-box2">
                <el-form-item label="">
                    <el-input v-model="search_word" placeholder="请输入设备ID"></el-input>
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

    export default {
        data: function(){
            const self = this;
            return {
                radio3:'online',
                search_word:'',
                loading:false,
                pageTotal:0,
                listData:[],
                currentPage:1,
                curUser:'',
                formLabelWidth:'120px',
                fullscreenLoading: false,
                showDeviceDetailDialog: false,
                selectedDevice: {},
                selectedGwSettings: {},
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

            getUser: function(){
                var self = this;
                self.$axios.post(baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra, type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        const user = res.data.extra;
                        self.curUser = user.userType;
                        if(self.curUser == '1' || self.curUser === '0'){
                            self.getData('/online')
                        } else {
                            self.$message({message:'用户类型错误', type:'warning'});
                        }
                    }
                })
            },

            getData: function(url){
                const self = this;
                self.loading = true;
                let params = { };
                if (self.curUser == '1') {
                    params['gw_channel'] = localStorage.getItem('ms_username');
                };
                self.$axios.post(baseUrl+'/device/list'+url, params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra, type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }

                    if(res.data.ret_code == 0){
                        self.pageTotal = res.data.extra.result.length || self.pageTotal;
                        if(!params.hasOwnProperty('current_page')){
                            self.listData = res.data.extra.result;
                        }else{
                            self.listData = res.data.extra.result;
                        }
                    } else {
                        self.$message({message:res.data.extra, type:'warning'});
                    }
                })
            },

            showDetail: function(row){
                this.selectedGwSettings = [];
                this.selectedDevice = [];
                this.selectedDevice = [
                    {key:'设备ID',value:row.deviceID},
                    {key:'设备名称',value:row.name},
                    {key:'设备地址', value:row.remoteAddress},
                    {key:'AW版本',value:row.awVersion},
                    {key:'在线客户数',value:row.onlineClients},
                    {key:'网络会话数',value:row.nfConntrackCount},
                    {key:'有线免认证',value:row.wiredPassed == '1'?'已开启':'未开启'},
                    {key:'wifidog运行时长',value:this.timeStamp(row.wifidogUptime)},
                    {key:'最近上线时间',value:this.dateForm(row.lastTime)},
                    {key:'CPU使用率',value:cpuLabel(row.cpuUsage)},
                    {key:'系统运行时长',value:timeStamp(row.sysUptime)},
                    {key:'系统剩余内存',value:bytesLabel(row.sysMemfree)},
                    {key:'系统负载',value:row.sysLoad}
                ];

                for (let i in row.gwSettings) {
                    this.selectedGwSettings.push({
                        gwID: row.gwSettings[i].gwID,
                        gwChannel: row.gwSettings[i].gwChannel,
                        authMode: row.gwSettings[i].authMode
                    });
                }

                console.log(this.selectedDevice, this.selectedGwSettings);
                this.showDeviceDetailDialog = true;
            },

            changeTab: function(){
                const url = '/'+this.radio3;
                this.currentPage = 1;
                this.getData(url);
            },

            handleCurrentChange:function(val){
                this.currentPage = val;
                var url = '';
                if(this.radio3 == 'all'){
                    url = '';
                }else{
                    url = '/'+this.radio3;
                }
                this.getData({page_size:10,current_page:this.currentPage},url);
            },

            search: function(){
                const self = this;
                if(self.search_word == ''){
                    self.$message({message:'输入不能为空',type:'warning'});
                    return false;
                }
                
                self.loading = true;
                let deviceID = self.search_word;
                let params = { };
                params['device_id'] = deviceID;
                if(localStorage.getItem('userType') == 1){//非超级管理员
                    params['gw_channel'] = localStorage.getItem('ms_username');
                }
                self.$axios.post(baseUrl+'/device/list',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.listData = res.data.extra.result;
                        self.pageTotal = res.data.extra.result.length;
                    } else {
                        self.$message({message:res.data.extra,type:'warning'});
                        self.listData = [];
                        self.pageTotal = 0;
                    }
                })

            },

            filterTag:function(value, row) {
                return row.status == value;
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
