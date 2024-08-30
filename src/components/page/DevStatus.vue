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
                    <el-input v-model="search_word" placeholder="请输入设备MAC"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="search">搜索</el-button>
                </el-form-item>
            </el-form>
        </div>

        <el-table :data="listData" border style="width: 100%" ref="multipleTable" v-loading="loading">
            <el-table-column prop="gwId" label="设备ID" width="150"></el-table-column>
            <el-table-column prop="deviceStatus" label="状态" width="80">
                <template slot-scope="scope">
                    <el-tag :type="scope.row.deviceStatus == '0' ? 'warning':'success'" close-transition>{{scope.row.deviceStatus == '1'?'在线':'离线'}}</el-tag>
                </template>
            </el-table-column>
            <!--
            <el-table-column prop="ssid" label="无线名称" width="150"></el-table-column>
            -->
            <el-table-column prop='onlineClients' label="在线客户数" width="110"></el-table-column>
            <el-table-column prop="channelPath" label="渠道" width="140"></el-table-column>
            <el-table-column prop="wiredPassed" label="有线免认证" width="110">
                <template slot-scope="scope">
                    <el-tag :type="scope.row.wiredPassed == '0' ? 'warning':'success'" close-transition>{{scope.row.wiredPassed == '1'?'已开启':'未开启'}}</el-tag>
                </template>
            </el-table-column>
            <!-- 
            <el-table-column prop="wifidogUptime" label="wifidog运行时长" width="160">
                <template slot-scope="scope">
                    {{timeStamp(scope.row.wifidogUptime)}}
                </template>
            </el-table-column>
            -->
            <el-table-column prop="lastTime" label="最近上线时间" width="190">
                <template slot-scope="scope">
                    {{dateForm(scope.row.lastTime)}}
                </template>
            </el-table-column>
            <el-table-column prop="remoteAddress" label="设备IP" width="150"></el-table-column>
            <el-table-column prop="auth" label="认证平台" width="100">
                <template slot-scope="scope">
                    <el-tag :type="scope.row.auth == '0' ? 'warning':'success'" close-transition>{{scope.row.auth == '1'?'已认证':'未认证'}}</el-tag>
                </template>
            </el-table-column>
            <el-table-column label="操作">
                <template slot-scope="scope">
                    <el-button class="btn1" size="small" type="info" @click="clickDetail(scope.row.gwId)">详情</el-button>
                    <!--<el-button class="btn1" size="small" type="info" @click="clickDialogPwd(scope.row.mac)">修改无线密码</el-button>-->
                    <!--<el-button class="btn1" v-if="curUser=='0' && scope.row.user_name" size="small" type="danger" @click="del(scope.row._id,scope.row.mac,scope.row.user_name)">删除路由</el-button>-->
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


        <el-dialog title="修改无线名称" :visible.sync="showDialogWifi" class="digcont">
            <el-form :model="formW" ref="formW" :rules="rulesW">
                <el-form-item label="无线名称" prop="ssid" :label-width="formLabelWidth">
                    <el-input v-model="formW.ssid" class="diainp" auto-complete="off"></el-input>
                    <!--<el-checkbox style="margin-left:20px;" v-model="formP.checked">显示密码</el-checkbox>-->
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="showDialogWifi = false">取 消</el-button>
                <el-button type="primary" @click="saveWifiNameChange('formW')" v-loading.fullscreen.lock="fullscreenLoading">确 定</el-button>
            </div>
        </el-dialog>

        <el-dialog title="修改无线密码" :visible.sync="showDialogPwd" class="digcont">
            <el-form :model="formP" ref="formP" :rules="rulesP">
                <el-form-item label="加密方式" prop="encryption" :label-width="formLabelWidth">
                    <!--<el-input v-model="formP.encryption" type="text" class="diainp" auto-complete="off"></el-input>-->
                    <el-select v-model="formP.encryption" placeholder="请选择加密方式">
                        <el-option key="none" label="无密码" value="none"></el-option>
                        <el-option key="psk-mixed+tkip+ccmp" label="WPA2-PSK强加密" value="psk-mixed+tkip+ccmp"> </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item v-if="formP.encryption == 'psk-mixed+tkip+ccmp'" label="无线密码" prop="user_password" :label-width="formLabelWidth">
                    <el-input v-model="formP.user_password" type="password" class="diainp" auto-complete="off"></el-input>
                    <!--<el-checkbox style="margin-left:20px;" v-model="formP.checked">显示密码</el-checkbox>-->
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="showDialogPwd = false">取 消</el-button>
                <el-button type="primary" @click="savePwdChange('formP')" v-loading.fullscreen.lock="fullscreenLoading">确 定</el-button>
            </div>
        </el-dialog>
    </div>
</template>

<script>
    import global_ from 'components/common/Global';
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
                formP:{
                    route_mac:'',
                    encryption:'none',
                    user_password:'',
                    checked:false,
                    pwdType:'password'
                },
                rulesP: {
                    user_password:[
                        {required: true, message: '请输入无线密码', trigger: 'blur'}
                    ],
                    user_validate_password:[
                        {required: true, message: '请输入确认密码', trigger: 'blur'},
                        {validator:this.validateRepwd,trigger:'blur'}
                    ]
                },
                showDialogPwd: false,
                showDialogWifi: false,
                fullscreenLoading: false,
                formW:{
                    route_mac:'',
                    ssid:''
                },
                rulesW: {
                    ssid:[
                        {required: true, message: '请输入无线名称', trigger: 'blur'}
                    ]
                },

            }
        },
        created: function(){
            this.getUser();
        },
        methods: {
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
            //毫秒数转为时间戳
            dateForm:function(time){
                var date = new Date(time);
                return date.toLocaleString();
            },
            getUser: function(){
                var self = this;
                self.$axios.post(global_.baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.curUser = res.data.ret_msg;
                        if(self.curUser == '1'){//普通管理员
                            self.getData({filter:{channelPath:localStorage.getItem('ms_username')}},'/online')
                        }else if(self.curUser == '0'){
                            self.getData({},'/online')
                        }
                    }
                })
            },
            clickDetail: function(mac){
                this.$router.push({path:'/devdetail',query:{gwId:mac}});
            },
            getData: function(params,url){
                var self = this;
                if(self.curUser == '1'){
                    var filter = {
                        channelPath: localStorage.getItem('ms_username')
                    };
                    params['filter'] = filter;
                }
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/device/list'+url ,params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.pageTotal = res.data.extra.count || self.pageTotal;
                        if(!params.hasOwnProperty('current_page')){
                            // self.pageTotal = res.data.extra.length;
                            // self.listData = res.data.extra.slice(0,10);
                            self.listData = res.data.extra.query;
                        }else{
                            // self.listData = res.data.extra;
                            self.listData = res.data.extra.query;
                        }
                    }
                })
            },
            reset: function(mac){
                var self = this;
                var params = {
                    route_mac:mac
                };
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/manage/reboot',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:'命令已下发',type:'success'})
                    }else{
                        self.$message.error(res.data.extra);
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
                self.$axios.post(global_.baseUrl+'/device/leave',params).then(function(res){
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
            clickDialogWifiName: function(mac){
                var self = this;
                self.showDialogWifi = true;
                self.formW.route_mac = mac;
            },
            clickDialogPwd: function(mac){
                var self = this;
                self.showDialogPwd = true;
                self.formP.route_mac = mac;
            },
            saveWifiNameChange:function(formName){
                var self = this;
                self.$refs[formName].validate(function(valid) {
                    if (valid) {
                        console.log('验证成功')
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                    var params = {
                        route_mac:self.formW.route_mac,
                        ssid:self.formW.ssid
                    };
                    // console.log(params);
                    self.fullscreenLoading  = true;
                    self.$axios.post(global_.baseUrl+'/manage/wireless',params).then(function(res){
                        self.showDialogWifi = false;
                        self.fullscreenLoading  = false;
                        if(res.data.ret_code == '1001'){
                            self.$message({message:res.data.extra,type:'warning'});
                            setTimeout(function(){
                                self.$router.replace('login');
                            },2000)
                        }
                        if(res.data.ret_code == 0){
                            self.$message({message:'修改成功',type:'success'});
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


                });
            },
            savePwdChange:function(formName){
                var self = this;
                self.$refs[formName].validate(function(valid) {
                    if (valid) {
                        console.log('验证成功')
                    } else {
                        return false;
                        console.log('验证失败');
                    }
                    var params = {
                        encryption:self.formP.encryption,
                        route_mac:self.formP.route_mac,
                        key:self.formP.encryption == 'none'?'':self.formP.user_password
                    };
                    // console.log(params);
                    self.fullscreenLoading  = true;
                    self.$axios.post(global_.baseUrl+'/manage/wireless',params).then(function(res){
                        self.fullscreenLoading  = false;
                        self.showDialogPwd = false;
                        if(res.data.ret_code == '1001'){
                            self.$message({message:res.data.extra,type:'warning'});
                            setTimeout(function(){
                                self.$router.replace('login');
                            },2000)
                        }
                        if(res.data.ret_code == 0){
                            self.$message({message:'修改成功',type:'success'});
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


                });
            },
            changeTab: function(){
                var url = '';
                if(this.radio3 == 'all'){
                    url = '';
                }else{
                    url = '/'+this.radio3;
                }
                this.currentPage = 1;
                this.getData({},url);
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
                self.$axios.post(global_.baseUrl+'/device/list',params).then(function(res){
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
