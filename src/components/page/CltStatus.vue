<template>
    <div class="table">
        <div class="crumbs">
            <el-breadcrumb separator="/">
                <el-breadcrumb-item><i class="el-icon-setting"></i> 设备管理</el-breadcrumb-item>
                <el-breadcrumb-item>认证用户</el-breadcrumb-item>
            </el-breadcrumb>
        </div>
        <div class='rad-group'>
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
            <el-table-column prop="deviceID" label="设备ID" width="150"></el-table-column>
            <el-table-column prop="gwID" label="认证网关ID" width="150"></el-table-column>
            <el-table-column prop="gwChannel" label="渠道" width="150"></el-table-column>
            <el-table-column prop="clients.mac" label="用户MAC" width="150"></el-table-column>
            <el-table-column prop="clients.ip" label="用户IP" width="150"></el-table-column>
            <el-table-column prop="clients.lastTime" label="最后在线时间" width="200">
                <template slot-scope="scope">
                    {{dateForm(scope.row.clients.lastTime)}}
                </template>
            </el-table-column>
            <el-table-column label="操作" width="200">
                <template slot-scope="scope">
                    <el-button type="text" @click="showDetail(scope.row)">详情</el-button>
                    <el-button class="btn1" size="small" type="danger" :disabled="!scope.row.isOnline" @click="kickOffline(scope.row)">
                        强制下线
                    </el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog :visible.sync="showClientDetailDialog" title="客户端详情" width="80%">
            <el-form :model="detailForm" label-width="200px">
                <el-table :data="selectedClient" border style="width: 50%">
                    <el-table-column prop="key" label="描述" width="150"></el-table-column>
                    <el-table-column prop="value" label="值" width="300"></el-table-column>
                </el-table>
            </el-form>
            <span slot="footer" class="dialog-footer">
            <el-button type="primary" @click="showClientDetailDialog = false">确定</el-button>
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
    import { baseUrl } from 'components/common/Global';
    import { timeStamp, dateForm, bandwidthLabel, search } from 'components/common/Helpers.js';

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
                showClientDetailDialog: false,
            }
        },

        created: function(){
            this.getUser();
        },

        methods: {
            timeStamp: timeStamp,
            dateForm: dateForm,
            bandwidthLabel: bandwidthLabel,
            search: search,

            getUser: function(){
                var self = this;
                self.$axios.post(baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        const user = res.data.extra;
                        self.curUser = user.userType;
                        if(self.curUser == '1' || self.curUser === '0'){
                            self.getData();
                        } else {
                            self.$message({message:'用户类型错误',type:'warning'});
                        }
                    }
                })
            },

            getData: function(){
                const self = this;
                self.loading = true;
                let params = { };
                if (self.curUser == '1') {
                    params['gw_channel'] = localStorage.getItem('ms_username');
                };
                self.$axios.post(baseUrl+'/client/list', params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
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
                        self.$message({message:res.data.extra,type:'warning'});
                    }
                })
            },

            showDetail: function(row){
                const self = this;
                self.showClientDetailDialog = true;
                self.selectedClient = [
                    {key:'用户MAC',value:row.clients.mac},
                    {key:'用户IP',value:row.clients.ip},
                    {key:'设备ID',value:row.deviceID},
                    {key:'认证网关ID',value:row.gwID},
                    {key:'渠道',value:row.gwChannel},
                    {key:'用户名',value:row.clients.name},
                    {key:'是否有线用户',value:row.clients.wired},
                    {key:'下行流量',value:self.bandwidthLabel(row.clients.incoming)},
                    {key:'上行流量',value:self.bandwidthLabel(row.clients.outgoing)},
                    {key:'认证方式',value:row.clients.authType},
                    {key:'认证时间',value:self.dateForm(row.clients.firstLogin)},
                    {key:'在线时长',value:self.timeStamp(row.clients.onlineTime)},
                    {key:'最后在线时间',value:self.dateForm(row.clients.lastTime)},
                    {key:'认证令牌',value:row.clients.token},
                ];
            },

            queryClientsOfDevice: function() {
                return this.search(baseUrl, '/client/list', this);
            },

            kickOffline: function(row){
                const self = this;
                const deviceID = row.deviceID;
                const gwID = row.gwID;
                const mac = row.clients.mac;
                const ip = row.clients.ip;
                self.$axios.post(baseUrl+'/client/kickoffClient', {device_id: deviceID, gw_id:gwID, mac:mac, ip:ip}).then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:'用户下线成功',type:'success'});
                        self.getData();
                    } else {
                        self.$message({message:res.data.extra,type:'warning'});
                    }
                })
            },
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
</style>
