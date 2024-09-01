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
                    <el-input v-model="search_word" placeholder="请输入认证网关ID"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="search">搜索</el-button>
                </el-form-item>
            </el-form>
        </div>

        <el-table :data="listData" border style="width: 100%" ref="multipleTable" v-loading="loading">
            <el-table-column prop="deviceID" label="设备ID" width="150"></el-table-column>
            <el-table-column prop="gwId" label="认证网关ID" width="150"></el-table-column>
            <el-table-column prop="gwChannel" label="渠道" width="150"></el-table-column>
            <el-table-column prop="clients.mac" label="用户MAC" width="150"></el-table-column>
            <el-table-column prop="clients.ip" label="用户IP" width="150"></el-table-column>
            <el-table-column prop="clients.name" label="用户名" width="150"></el-table-column>
            <el-table-column prop="clients.incoming" label="下行流量" width="150"></el-table-column>
            <el-table-column prop="clients.outgoing" label="上行流量" width="150"></el-table-column>
            <el-table-column prop="clients.authType" label="认证方式" width="150"></el-table-column>
            <el-table-column prop="clients.firstLogin" label="认证时间" width="150">
                <template slot-scope="scope">
                    <span>{{dateForm(scope.row.clients.firstLogin)}}</span>
                </template>
            </el-table-column>
            <el-table-column prop="clients.onlineTime" label="在线时长" width="150">
                <template slot-scope="scope">
                    <span>{{timeStamp(scope.row.clients.onlineTime)}}</span>
                </template>
            </el-table-column>
            <el-table-column prop="clients.lastTime" label="最后在线时间" width="150">
                <template slot-scope="scope">
                    <span>{{dateForm(scope.row.clients.lastTime)}}</span>
                </template>
            </el-table-column>
            <el-table-column label="操作" width="150">
                <template slot-scope="scope">
                    <el-tooltip class="item" effect="dark" content="查看详情" placement="top">
                        <el-button type="text" icon="el-icon-search" @click="showDialog(scope.row)"></el-button>
                    </el-tooltip>
                </template>
            </el-table-column>
        </el-table>
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
    import { timeStamp, dateForm, bandwidthLabel } from 'components/common/Helpers.js';

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
            }
        },

        created: function(){
            this.getUser();
        },

        methods: {
            timeStamp: timeStamp,
            dateForm: dateForm,
            bandwidthLabel: bandwidthLabel,

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
                        self.pageTotal = res.data.extra.clients.length || self.pageTotal;
                        if(!params.hasOwnProperty('current_page')){
                            self.listData = res.data.extra.clients;
                        }else{
                            self.listData = res.data.extra.clients;
                        }
                    } else {
                        self.$message({message:res.data.extra,type:'warning'});
                    }
                })
            },

            del:function(iid,mac,username){
                var self = this;
                var params = {
                    _id:iid,
                    route_mac:mac,
                    user_name:username
                };
                self.loading = true;
                self.$axios.post(baseUrl+'/device/leave',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:'已删除账号 "'+localStorage.getItem('ms_username')+'" 下的路由',type:'success'});
                        var url = '';
                        if(self.radio3 == 'all'){
                            url = '';
                        }else{
                            url = '/'+self.radio3;
                        }
                        self.getData({page_size:10,current_page:self.currentPage},url);
                    }else{
                        self.$message.error(res.data.extra);
                    }
                })
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
                var self = this;
                var reg_name = /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
                var reg_name2 = /^[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}$/;
                if(self.search_word == ''){
                    self.$message({message:'输入不能为空',type:'warning'});
                    return false;
                }
                if(!reg_name.test(self.search_word) && !reg_name2.test(self.search_word)){
                    self.$message({message:'设备MAC输入有误',type:'warning'});
                    return false;
                }
                self.loading = true;
                var mac = self.search_word;
                var str = (mac.indexOf(':')>=0?mac.replace(/:/g,''):mac).toUpperCase();
                var params = {
                    filter:{"gwId":str}
                };
                if(localStorage.getItem('userType') == 1){//非超级管理员
                    params.filter.channelPath = localStorage.getItem('ms_username');
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
                        self.pageTotal = res.data.extra.count;
                        self.listData = res.data.extra.query;
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
</style>
