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
                <el-table-column prop="onlineUser" label="在线用户" width="160">
                    <template slot-scope="scope">
                        {{currentOnlineUser(scope.row.clients)}}
                    </template>
                </el-table-column>
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
                <el-table-column prop="version" label="版本"></el-table-column>
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
                        <el-tag :type="scope.row.clients.telNumber == '' ? 'info' : 'success'" close-transition>{{scope.row.clients.telNumber == ''?'无电话号码': scope.row.clients.telNumber}}</el-tag>
                    </template>
                </el-table-column>
                <!--
                <el-table-column prop="clients.wired" label="有线设备" width="50">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.clients.wired == '1' ? 'success' : 'danger'" close-transition>{{scope.row.clients.wired == '1'?'是': '否'}}</el-tag>
                    </template>
                </el-table-column>
                -->
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
                <!--<el-table-column prop="pubsub_status" label="升级状态">-->
                    <!--<template slot-scope="scope">-->
                        <!--<el-tag :type="scope.row.pubsub_status == 'response_ok' ? 'success' : (scope.row.pubsub_status == 'response_fail'?'danger':'warning')" close-transition>{{scope.row.pubsub_status == 'response_ok'?'成功': (scope.row.pubsub_status == 'response_fail'?'失败':'执行中')}}</el-tag>-->
                    <!--</template>-->
                <!--</el-table-column>-->
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
    import global_ from 'components/common/Global';
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
            getParams: function(){
                var self = this;
                self.curGwid = self.$route.query.gwId;
                self.isShow = 'apps';
                self.getDetailData({});
                self.getDevMsg();
            },
            getFirmwareData: function(params){
                var self = this;
                params.uuid = self.curId;
                self.$axios.post(global_.baseUrl+'/task/list/detail',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        // self.firmwareData = res.data.extra;
                        self.firmwareData1 = res.data.extra.resultList.slice(0,1);
                        self.pageTotal = res.data.extra.count || self.pageTotal;
                        if(!params.hasOwnProperty('current_page')){
                            self.firmwareData = res.data.extra.resultList;
                        }else{
                            self.firmwareData = res.data.extra.resultList;
                        }
                    }else{
                        self.$message.error(res.data.extra)
                    }
                },function(err){
                    self.loading = false;
                    console.log(err);
                });
            },
            //时间转换
            timeStamp: function( second_time ){
                var time = parseInt(second_time) + "秒";
                if( parseInt(second_time )> 60){
                    var second = parseInt(second_time) % 60;
                    var min = parseInt(second_time / 60);
                    time = min + "分" + second + "秒";
                    if( min > 60 ){
                        min = parseInt(second_time / 60) % 60;
                        var hour = parseInt( parseInt(second_time / 60) /60 );
                        time = hour + "小时" + min + "分" + second + "秒";
                        if( hour > 24 ){
                            hour = parseInt( parseInt(second_time / 60) /60 ) % 24;
                            var day = parseInt( parseInt( parseInt(second_time / 60) /60 ) / 24 );
                            time = day + "天" + hour + "小时" + min + "分" + second + "秒";
                        }
                    }
                }
                return time;
            },
            isOffline:function(time){
                var now             = new Date();
                var nowTime	        = now.getTime();
                if ((nowTime - time) > 60*5*1000)
                    return true;
                return false;
            },
            //毫秒数转为时间戳
            dateForm:function(time){
                var now             = new Date();
                var nowTime	        = now.getTime();
                if ((nowTime - time) > 60*5*1000)
                    return "用户离线";
                var date = new Date(time);
                return date.toLocaleString();
            },
            //连接设备速率转换
            bandwidthLabel: function(by){
                var kby = (by / 1024).toFixed(2);
                var uby = 'KB';
                if (kby >= 1024) {
                    uby = 'MB';
                    kby = (kby / 1024).toFixed(2);
                }
                return kby + " " + uby;
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
                if(localStorage.getItem('userMsg') == 1){//非超级管理员
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
            currentOnlineUser:function(clients) {
                var onlineUser = 0;
                var now             = new Date();
                var nowTime	        = now.getTime();
                for (var i = 0; i < clients.length; i++)
                {
                    if ((nowTime - clients[i].lastTime) <= 60*5*1000)
                        onlineUser++;
                }
                return onlineUser;
            },
        },
    }
</script>
<style>
    .rad-group{margin-bottom:20px;}
    .handle-input{  width: 300px;  display: inline-block;  }
    .handle-box2{display:inline-block;float:right;}
</style>
