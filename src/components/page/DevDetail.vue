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
            <el-table :data="devMsgData" border style="width: 100%;margin:20px 0 40px;" ref="multipleTable">
                <el-table-column prop="onlineClients" label="在线用户" width="160"></el-table-column>
                <el-table-column prop="sysUptime" label="系统运行时长" width="160">
                    <template slot-scope="scope">
                        {{timeStamp(scope.row.sysUptime)}}
                    </template>
                </el-table-column>
                <el-table-column prop="sysMemfree" label="剩余内存">
                    <template slot-scope="scope">
                        {{((scope.row.sysMemfree)/1024).toFixed(2) + 'M'}}
                    </template>
                </el-table-column>
                <el-table-column prop="sysLoad" label="系统负载"></el-table-column>
                <el-table-column prop="cpuUsage" label="cpu利用率"></el-table-column>
                <el-table-column prop="aw_version" label="apfree-wifidog版本"></el-table-column>
                <el-table-column prop="fm_version" label="固件版本"></el-table-column>
                <el-table-column prop="type" label="设备类型"></el-table-column>
                <el-table-column prop="name" label="设备名称"></el-table-column>
            </el-table>
            <hr style="margin-bottom:40px;height:1px;border:none;border-top:1px solid #ddd;">
            <el-table :data="gwClients" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="clients.mac" label="路由MAC" width="180"></el-table-column>
                <el-table-column prop="clients.ip" label="终端IP" width="150"></el-table-column>
                <el-table-column prop="clients.authType" label="当前认证方式" width="120">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.clients.authType == 1 ? 'success' : 'info'" close-transition>{{scope.row.clients.authType == 1?'电话认证': '其他认证'}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="clients.telNumber" label="电话号码" width="150">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.clients.telNumber == '' ? 'info' : 'success'" close-transition>{{displayClientPhone(scope.row.clients)}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="clients.name" label="终端名称" width="220"></el-table-column>
                <el-table-column prop="clients.incoming" label="下行流量" width="120">
                    <template slot-scope="scope">
                        {{bandwidthLabel(scope.row.clients.incoming || 0)}}
                    </template>
                </el-table-column>
                <el-table-column prop="clients.outgoing" label="上行流量" width="120">
                    <template slot-scope="scope">
                        {{bandwidthLabel(scope.row.clients.outgoing || 0)}}
                    </template>
                </el-table-column>
                <el-table-column prop="clients.onlineTime" label="在线时长" width="150">
                    <template slot-scope="scope">
                        {{timeStamp(scope.row.clients.onlineTime)}}
                    </template>
                </el-table-column>
                <el-table-column prop="clients.lastTime" label="最近访问时间" width="200">
                    <template slot-scope="scope">
                        <el-tag :type="isOffline(scope.row.clients.lastTime) ? 'warning':'success'" close-transition>
                            {{dateForm(scope.row.clients.lastTime)}}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width=200>
                    <template slot-scope="scope">
                        <el-button class="btn1" type="warning" size="small" v-if="!scope.row.clients.kickoff" @click="handleCltOffline(scope.row.clients.mac)">下线</el-button>
                        <el-button class="btn1" :type="!scope.row.clients.isTelBlocked?'danger':'success'" size="small" :disabled="scope.row.clients.telNumber == ''" @click="handleBlockClient(scope.row.clients.mac,scope.row.clients.isTelBlocked)">{{scope.row.clients.isTelBlocked?'解除电话黑名单':'电话黑名单'}}</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
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
    import {baseUrl} from 'components/common/Global';
    import {timeStamp, dateForm, isOffline, bandwidthLabel} from 'components/common/Helpers.js';

    export default {
        data: function(){
            const self = this;
            return {
                curGwid:'',
                loading:false,
                radio3:'ROM升级',
                gwClients:[],
                devMsgData:[],
                pageTotal:0,
                currentPage:1,

            }
        },
        created: function(){
            this.getParams();
        },
        methods: {
            timeStamp: timeStamp,
            dateForm: dateForm,
            isOffline: isOffline,
            bandwidthLabel: bandwidthLabel,

            getParams: function(){
                var self = this;
                self.curGwid = self.$route.query.gwId;
                self.isShow = 'apps';
                self.getDetailData({});
                self.getDevMsg();
            },

            getDetailData: function(params){
                var self = this;
                params.gwId = self.curGwid;
                self.$axios.post(global_.baseUrl+'/client/list',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        // self.pageTotal = res.data.extra.count || self.pageTotal;
                        self.gwClients = res.data.extra.gwClients;
                    }else{
                        self.$message.error(res.data.extra)
                    }
                },function(err){
                    self.loading = false;
                    console.log(err);
                });
            },

            getDevMsg: function(){
                var self = this;
                var params = {
                    filter:{"gwId":self.curGwid}
                };
                if(localStorage.getItem('userType') == 1){//非超级管理员
                    params.filter.channelPath = localStorage.getItem('ms_username');
                }
                self.$axios.post(global_.baseUrl+'/device/list',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.devMsgData = res.data.extra.query;
                    }
                })
            },

            handleCurrentChange:function(val){
                var self = this;
                self.currentPage = val;
                var params = {
                    page_size:10,
                    current_page:this.currentPage
                };
                self.getDetailData(params);

            },

            handleCltOffline: function(mac){
                var self = this;
                var params = {
                    filter:{"gwId":self.curGwid, "clients.mac":mac}
                };
                
                this.$confirm('此操作将该用户踢下线, 是否继续?', '提示', {
                  confirmButtonText: '确定',
                  cancelButtonText: '取消',
                  type: 'warning'
                }).then(() => {
                    self.$axios.post(global_.baseUrl+'/client/kickoffClient',params).then(function(res){
                        self.loading = false;
                        if(res.data.ret_code == '1001'){
                            self.$message({message:res.data.extra,type:'warning'});
                            setTimeout(function(){
                                self.$router.replace('login');
                            },2000)
                        } else if(res.data.ret_code == 0){
                            self.gwClients = res.data.extra.gwClients;
                            this.$message({
                                type: 'success',
                                message: '操作成功!'
                            });
                        }
                    });
                });
            },

            handleBlockClient: function(mac, isTelBlocked) {
                var self = this;
                var params = {
                    filter:{"gwId":self.curGwid, "mac":mac, "isTelBlocked":isTelBlocked}
                };
                console.log('params is ' + params.filter);
                this.$confirm(isTelBlocked==false?'此操作将禁止该电话号认证上网功能, 是否继续?':'此操作将恢复该电话号认证上网功能，是否继续?', '提示', {
                  confirmButtonText: '确定',
                  cancelButtonText: '取消',
                  type: 'warning'
                }).then(() => {
                    self.$axios.post(global_.baseUrl+'/client/blockClient',params).then(function(res){
                        self.loading = false;
                        if(res.data.ret_code == '1001'){
                            self.$message({message:res.data.extra,type:'warning'});
                            setTimeout(function(){
                                self.$router.replace('login');
                            },2000)
                        }else if(res.data.ret_code == 0){
                            self.gwClients = res.data.extra.gwClients;
                            this.$message({
                                type: 'success',
                                message: '操作成功!'
                            });
                        }
                    });
                });
            },

            changePage:function(values) {
                this.information.pagination.per_page = values.perpage;
                this.information.data = this.information.data;
            },

            onSearch:function(searchQuery) {
                this.query = searchQuery;
            },
            
            displayClientPhone:function(client) {
                if (client.authType != 1)
                    return '号码不展示';
                if (client.telNumber == '')
                    return '无电话号码';
                
                return client.telNumber;
            },
        },
    }
</script>
<style>
    .rad-group{margin-bottom:20px;}
    .handle-input{  width: 300px;  display: inline-block;  }
    .handle-box2{display:inline-block;float:right;}
</style>
