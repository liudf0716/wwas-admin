<template>
    <div class="table" v-loading="loading2">
        <div v-if="isSuper =='0'?true:false">
            <div class="crumbs">
                <el-breadcrumb separator="/">
                    <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道管理</el-breadcrumb-item>
                    <el-breadcrumb-item>渠道列表</el-breadcrumb-item>
                </el-breadcrumb>
            </div>
            <el-form :inline="true" class="handle-box">
                <el-form-item>
                    <el-button type="primary" icon="plus" :disabled="isSuper=='0'?false:true" class="handle-del mr10" @click="dialogFormVisible=true">新建子渠道</el-button>
                </el-form-item>
                <el-form-item label="">
                    <el-input v-model="search_word" placeholder="请输入渠道名称或账号查找" class="handle-input mr10"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" icon="search" :disabled="isSuper=='0'?false:true" @click="search">查询</el-button>
                </el-form-item>
            </el-form>
            <div class='rad-group' v-if="isSuper =='0'?true:false">
                <el-radio-group v-model="radio3" @change="changeTab">
                    <el-radio-button label="all">全部</el-radio-button>
                    <el-radio-button label="0">未冻结</el-radio-button>
                    <el-radio-button label="1">已冻结</el-radio-button>
                </el-radio-group>
            </div>
            <el-table :data="userData" border style="width: 100%" ref="multipleTable" :empty-text="emptyMsg" v-loading="loading">
                <el-table-column prop="user_account" label="账 号" width="150"></el-table-column>
                <el-table-column prop="user_name" label="渠道名称"></el-table-column>
                <el-table-column prop="user_phone" label="联系电话" width="130"></el-table-column>
                <el-table-column prop="user_status" label="冻结状态" width="120">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.user_status == '1' ? 'warning' : 'success'" close-transition>{{scope.row.user_status=='1'?'已冻结':'未冻结'}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="渠道类型" width="120">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.user_type == '0' ? 'danger' : 'info'" close-transition>{{scope.row.user_type == '0'?'超级管理员':'管理员'}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="user_create_time" label="创建时间" width="150"></el-table-column>
                <el-table-column label="在线设备" width="100">
                    <template slot-scope="scope">
                        <el-tag type="warning">{{scope.row.user_online_count + '/ ' + scope.row.user_device_count}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="380">
                    <template slot-scope="scope">
                        <!--<el-button class="btn1" size="small" type="text" @click="resetPwd(scope.row.user_account)">修改密码</el-button>-->
                        <el-button class="btn1" size="small" type="text" @click="resetPassword(scope.row.user_account)">重置密码</el-button>
                        <el-button class="btn1" size="small" v-if="scope.row.user_type =='1'?true:false" type="text" @click="toRouter(scope.row.user_account)">导入路由</el-button>
                        <el-button class="btn1" size="small" v-if="scope.row.user_type =='1'?true:false" type="text" @click="outRouter(scope.row.user_account)">导出路由</el-button>
                        <!--<el-button class="btn1" size="small" v-if="scope.row.user_type =='1'?true:false" type="text" @click="delRouter(scope.row.user_account)">删除路由</el-button>-->
                        <el-button class="btn1" size="small" v-if="scope.row.user_status =='0' && scope.row.user_type =='1'" @click="revoke(scope.row.user_account)" :type="scope.row.user_status == '1' ? 'warning' : 'danger'">冻结账户</el-button>
                        <el-button class="btn1" size="small" v-else-if="scope.row.user_status =='1' && scope.row.user_type =='1'" @click="restore(scope.row.user_account)" :type="scope.row.user_status == '1' ? 'warning' : 'danger'">解冻账户</el-button>
                        <el-button class="btn1" size="small" v-if="scope.row.user_type =='1'?true:false" type="success" @click="toEnter(scope.row.user_account)">点击进入</el-button>
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
        <div v-if="isSuper == '0'?false:true">
            <div class="crumbs">
                <el-breadcrumb separator="/">
                    <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道管理</el-breadcrumb-item>
                    <!--<el-breadcrumb-item>渠道信息</el-breadcrumb-item>-->
                </el-breadcrumb>
            </div>
            <el-table :data="noSuperData" border style="width: 100%" ref="multipleTable">
                <el-table-column prop="user_account" label="账 号"></el-table-column>
                <el-table-column label="操作">
                    <template slot-scope="scope">
                        <el-button class="btn1" size="small" type="success" @click="toRouter(scope.row.user_account)">导入路由</el-button>
                        <el-button class="btn1" size="small" type="warning" @click="outRouter(scope.row.user_account)">导出路由</el-button>
                        <el-button class="btn1" size="small" type="success" @click="outClient(scope.row.user_account)">导出用户</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
        <el-dialog title="修改密码" :visible.sync="showDialogPwd" class="digcont">
            <el-form :model="formP" ref="formP" :rules="rulesP">
                <el-form-item label="密码" prop="user_password" :label-width="formLabelWidth">
                    <el-input v-model="formP.user_password" type="password" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="新密码" prop="user_new_password" :label-width="formLabelWidth">
                    <el-input v-model="formP.user_new_password" type="password" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="确认密码" prop="user_validate_password" :label-width="formLabelWidth">
                    <el-input v-model="formP.user_validate_password" type="password" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="showDialogPwd = false">取 消</el-button>
                <el-button type="primary" @click="savePwdChange('formP')" v-loading.fullscreen.lock="fullscreenLoading">确 定</el-button>
            </div>
        </el-dialog>
        <el-dialog title="新建子渠道" :visible.sync="dialogFormVisible" class="digcont">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item label="账号" prop="user" :label-width="formLabelWidth">
                    <el-input v-model="form.user" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="密码" prop="password" :label-width="formLabelWidth">
                    <el-input v-model="form.password" type="password" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="渠道名称" prop="name" :label-width="formLabelWidth">
                    <el-input v-model="form.name" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="联系电话" prop="tel" :label-width="formLabelWidth">
                    <el-input v-model="form.tel" class="diainp" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="地址" :label-width="formLabelWidth">
                    <el-select size="small" style="width: 110px"
                               v-model="form.selectProv"
                               placeholder="请选择省份"
                               v-on:change="getProv($event)">
                        <el-option
                            v-for="item in provs"
                            :key="item.label"
                            :label="item.label"
                            :value="item.value">
                        </el-option>
                    </el-select>
                    <el-select size="small" style="width: 104px"
                               v-if="form.selectProv!=''"
                               v-model="form.selectCity"
                               placeholder="请选择城市"
                               v-on:change="getCity($event)">
                        <el-option
                            v-for="item in citys"
                            :key="item.label"
                            :label="item.label"
                            :value="item.value">
                        </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="" :label-width="formLabelWidth">
                    <el-input v-model="form.addr" class="diainp2" auto-complete="off" placeholder="请输入详细地址"></el-input>
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="dialogFormVisible = false">取 消</el-button>
                <el-button type="primary" @click="saveCreate('form')">创 建</el-button>
            </div>
        </el-dialog>

        <el-dialog title="导入路由" :visible.sync="showRouterDialog" class="digcont">
            <el-tabs v-model="activeName2" type="card" @tab-click="handleClick">
                <el-tab-pane label="文件上传" name="1">
                    <div>
                        <h4>下载示范模板</h4>
                        <p class="mb30">
                            路由导入模板.xls
                            <a href="http://cloud.kunteng.org/yunac/static/tmp/routers.xls" target="_blank">
                                <el-button class="btn1" size="small" type="primary">下载</el-button>
                            </a>
                        </p>
                    </div>
                    <div>
                        <h4>上传</h4>
                        <el-form :model="formMacfile" ref="formMacfile">
                            <el-form-item label="">
                                <el-upload
                                    class="upload-demo"
                                    ref="upload"
                                    name="file_name"
                                    :action="uploadUrl"
                                    with-credentials="true"
                                    :data="formMacfile"
                                    :beforeUpload="beforeUpload"
                                    :on-change="handleChange"
                                    :on-success="handleSuccess"
                                    :file-list="fileList"
                                    :auto-upload="false">
                                    <el-button slot="trigger" size="small" type="primary">选取文件</el-button>                                   
                                </el-upload>
                            </el-form-item>
                        </el-form>
                    </div>
                    <div class="mt30">
                        <el-button @click="showDialog == false">取 消</el-button>
                        <el-button type="primary" @click="fileAdd('formMacfile')">保 存</el-button>
                    </div>
                </el-tab-pane>
                <el-tab-pane label="手动导入" name="2">
                    <el-form :model="formRouter2" ref="formRouter2" :rules="rulesRouter2">
                        <el-form-item label="设备ID" prop="device_id">
                            <el-input v-model="formRouter2.device_id" class="diainp"></el-input>
                        </el-form-item>
                        <el-form-item label="启用认证网关设备" prop="route_mac">
                            <el-input
                                type="textarea"
                                :rows="2"
                                placeholder="请输入网关ID，如果要输入多个，每行输入一个；网关ID一般为MAC地址，格式为12位字母或数字组合，不区分大小写"
                                v-model="formRouter2.route_mac">
                            </el-input> 
                        </el-form-item>
                        <el-form-item label="启用单次认证网关设备" prop="route_mac_once_auth">
                            <el-input
                                type="textarea"
                                :rows="2"
                                placeholder="请输入网关ID，如果要输入多个，每行输入一个；网关ID一般为MAC地址，格式为12位字母或数字组合，不区分大小写"
                                v-model="formRouter2.route_mac_once_auth">
                            </el-input> 
                        </el-form-item>
                        <el-form-item label="单次认证免认证时长" prop="next_auth_time">
                            <el-input 
                            v-model="formRouter2.next_auth_time" 
                            placeholder="请输入免认证时长"
                            class="diainp">
                            </el-input>
                        </el-form-item>
                    </el-form>
                    <div class="mt30">
                        <el-button @click="showRouterDialog = false">取 消</el-button>
                        <el-button type="primary" @click="saveToRouterChange('formRouter2')">保 存</el-button>
                    </div>
                </el-tab-pane>
            </el-tabs>
        </el-dialog>
        <el-dialog title="删除路由" :visible.sync="showDelRouterDialog" class="digcont">
            <div style="margin-bottom:16px;">*批量添加功能MAC之间以换行分割，每行一个MAC；MAC格式为12位字母或数字组合，不区分大小写:</div>
            <el-form :model="formRouter3" ref="formRouter3" :rules="rulesRouter3">
                <el-form-item prop="route_mac">
                    <el-input
                        type="textarea"
                        :rows="5"
                        placeholder="请输入内容"
                        v-model="formRouter3.route_mac">
                    </el-input>
                </el-form-item>
            </el-form>
            <div class="mt30">
                <el-button @click="showDelRouterDialog = false">取 消</el-button>
                <el-button type="primary" @click="saveDelRouterChange('formRouter3')">保 存</el-button>
            </div>
        </el-dialog>

    </div>
</template>

<script>
    import  md5 from 'js-md5';
    import global_ from 'components/common/Global';
    var crypto = require('crypto');
    export default {
        data: function() {
            return {
                uploadUrl:global_.baseUrl+'/device/import/excel',
                radio3:'online',
                isSuper:localStorage.getItem('userMsg'),
                loading2:false,
                dialogFormVisible: false,
                noSuperData:[],
                form: {
                    user:'',
                    password:'',
                    name: '',
                    tel:'',
                    selectProv: '',
                    selectCity: '',
                    addr:'',
                    region: '',
                    date1: '',
                    date2: '',
                    delivery: false,
                    type: [],
                    resource: '',
                    desc: ''
                },
                rules: {
                    user:[
                        {required: true, message: '请输入账号', trigger: 'blur'},
                        {validator:this.validateSpace,trigger:'blur'}
                    ],
                    password:[
                        {required: true, message: '请输入密码', trigger: 'blur'},
                        {validator:this.validateSpace,trigger:'blur'},
                        {min:3,max:32,message:'长度在3到32个字符',trigger:'blur'},
                        {validator:this.validatePwd,trigger:'blur'}
                    ],
                    name:[
                        {required: true, message: '请输入渠道名称', trigger: 'blur'},
                        {validator:this.validateSpace,trigger:'blur'},
                        {validator:this.validateSpace,trigger:'blur'}
                    ],
                    tel:[
                        {required: true, message: '请输入联系电话', trigger: 'blur'},
                        {validator:this.validateTel,trigger:'blur'}
                    ]
                },
                formLabelWidth: '120px',
                provs:global_.provs,
                citys: [],
                showRouterDialog:false,
                showDelRouterDialog:false,
                radiotoRout:'文件上传',
                fileList:[],
                search_word:'',
                activeName2:'1',
                textarea_macs:'',

                userData:[],
                loading:false,
                pageTotal:0,
                currentPage:1,
                emptyMsg:'暂无数据',
                formP:{
                    user_account:localStorage.getItem('ms_username'),
                    user_password:'',
                    user_new_password:'',
                    user_validate_password:''
                },
                rulesP: {
                    user_password:[
                        {required: true, message: '请输入密码', trigger: 'blur'}
                    ],
                    user_new_password:[
                        {required: true, message: '请输入新密码', trigger: 'blur'}
                    ],
                    user_validate_password:[
                        {required: true, message: '请输入确认密码', trigger: 'blur'},
                        {validator:this.validateRepwd,trigger:'blur'}
                    ]
                },
                showDialogPwd: false,
                curAccount:'',
                curAccount2:'',
                curAccount3:'',
                fullscreenLoading: false,
                formRouter2:{route_mac:''},
                rulesRouter2: {
                    route_mac: [
                        {required: true, message: '请输入MAC', trigger: 'blur'},
                        {validator: this.validateMac, trigger: 'blur'}
                    ]
                },
                formRouter3:{route_mac:''},
                rulesRouter3: {
                    route_mac: [
                        {required: true, message: '请输入MAC', trigger: 'blur'},
                        {validator: this.validateMac, trigger: 'blur'}
                    ]
                },
                formMacfile:{
                    user_name:'',
                    user_name3:''
                }
            }
        },
        created: function(){
            this.getUsers({},'all');
        },
        methods: {
            getUsers: function(params,url){//获取渠道列表
                var self = this;
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/admin/'+url,params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){//未登录状态
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == '1010'){//权限不足
                        // self.emptyMsg = res.data.extra;
                        self.noSuperData = [{
                            user_account:self.formP.user_account
                        }]
                    }
                    if(res.data.ret_code == 0){
                        self.pageTotal = res.data.extra.count || self.pageTotal;
                        if(!params.hasOwnProperty('current_page')){
                            // self.pageTotal = res.data.extra.length;
                            // self.userData = res.data.extra.slice(0,10);
                            self.userData = res.data.extra.allAdmin;
                        }else{
                            self.userData = res.data.extra.allAdmin;
                        }
                    }
                })
            },
            changeTab: function(){
                var self = this;
                var params = {};
                self.currentPage = 1;
                if(self.radio3 == 'all'){
                    self.currentPage = 1;
                    self.getUsers(params,'all');
                }else{
                    self.getUsers({user_status:self.radio3},'status');
                }
            },
            revoke: function(account){//冻结操作
                var self = this;
                var params = {
                    user_account:account
                };
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/admin/revoke',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 1){
                        self.$message({message:res.data.extra,type:'warning'});
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:res.data.extra,type:'success'});
                        if(self.radio3 == 'all'){
                            self.getUsers({page_size:10,current_page:self.currentPage},'all');
                        }else{
                            self.getUsers({user_status:self.radio3,page_size:10,current_page:self.currentPage},'status');
                        }
                    }

                },function(err){
                    self.$message.error('操作失败');
                    self.loading = false;
                    console.log(err);
                })

            },
            restore: function(account){//解冻操作
                var self = this;
                var params = {
                    user_account:account
                };
                self.loading = true;
                self.$axios.post(global_.baseUrl+'/admin/restore',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:res.data.extra,type:'success'});
                        var param = {};
                        if(self.radio3 == 'all'){
                            self.getUsers({page_size:10,current_page:self.currentPage},'all');
                        }else{
                            self.getUsers({user_status:self.radio3,page_size:10,current_page:self.currentPage},'status');
                        }
                    }

                },function(err){
                    self.$message.error('操作失败');
                    self.loading = false;
                    console.log(err);
                })

            },
            getUser: function(){
                var self = this;
                self.$axios.post(global_.baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == 0){
                        localStorage.setItem('userMsg',res.data.ret_msg);
                        if(res.data.ret_msg == '1'){//普通管理员

                        }
                        setTimeout(function(){
                            // self.$router.push('/setpush')
                            self.$router.push({path:'/'});
                        },2000)

                    }
                })
            },
            toEnter: function(user){
                var self = this;
                self.loading = true;
                var params = {
                    user_account:user
                };
                self.$axios.post(global_.baseUrl+'/admin/switch',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == '1003'){
                        self.emptyMsg = res.data.extra;
                    }
                    if(res.data.ret_code == 0){
                        self.$message({message:res.data.extra,type:'success'});
                        localStorage.setItem('ms_username',user);
                        localStorage.setItem('userMsg','1');
                        window.location.reload();
                    }else{
                        self.$message.error(res.data.extra);
                    }
                })
            },
            saveCreate: function(formName){
                let self = this;
                self.$refs[formName].validate(function(valid){
                    if(valid){
                        console.log('验证成功')
                    }else{
                        return false;
                        console.log('验证失败');
                    }
                    let params = {
                        user_account:self.form.user,
                        user_password:md5(self.form.password),
                        user_name:self.form.name,
                        user_phone:self.form.tel,
                        user_city:self.form.selectProv+self.form.selectCity+self.form.addr
                    };
                    self.$axios.post(global_.baseUrl + '/admin/register',params).then(function(res){
                        if(res.data.ret_code == '1001'){
                            self.$message({message:res.data.extra,type:'warning'});
                            setTimeout(function(){
                                self.$router.replace('login');
                            },2000)
                        }
                        if(res.data.ret_code == 0){
                            self.$message('注册成功！');
                            self.form.user = '';
                            self.form.password = '';
                            self.form.name = '';
                            self.form.tel = '';
                            self.form.selectProv = '';
                            self.form.selectCity = '';
                            self.form.addr = '';
                            self.radio3 = 'all';
                            self.dialogFormVisible = false;
                            self.getUsers({},'all');
                        }else{
                            self.$message(res.data.extra);
                        }
                    })

                });

            },
            search: function(){
                var self = this;
                if(self.search_word == ''){
                    self.$message({message:'输入不能为空',type:'warning'});
                    return false;
                }
                self.loading = true;
                var params = {
                    user:self.search_word
                };
                self.$axios.post(global_.baseUrl+'/admin/query',params).then(function(res){
                    self.loading = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == '1003'){
                        self.emptyMsg = res.data.extra;
                    }
                    if(res.data.ret_code == 0){
                        if(JSON.stringify(params) == '{}'){
                            self.pageTotal = res.data.data.length;
                            self.userData = res.data.data.slice(0,10);
                        }else{
                            self.userData = res.data.data;
                        }
                    }
                })

            },
            resetPwd: function(account){
                var self = this;
                self.showDialogPwd = true;
                self.curAccount = account;
            },
            resetPassword:function(account){
                var self = this;
                var params = {
                    user_account:account
                }
                self.loading  = true;
                self.$axios.post(global_.baseUrl+'/admin/reset',params).then(function(res){
                    self.loading  = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        self.showDialogPwd = false;
                        self.$message({message:res.data.extra,type:'success'})
                    }else{
                        self.$message.error(res.data.extra);
                    }
                },function(err){
                    self.loading  = false;
                    self.$message.error(err);
                })

            },
            savePwdChange: function(formName){
                var self = this;
                self.$refs[formName].validate(function(valid){
                    if(valid){
                        var params = {
                            user_account: self.curAccount,
                            user_password:md5(self.formP.user_password),
                            user_new_password: md5(self.formP.user_new_password)
                        };
                        self.fullscreenLoading  = true;
                        self.$axios.post(global_.baseUrl+'/admin/change',params).then(function(res){
                            self.fullscreenLoading  = false;
                            if(res.data.ret_code == '1001'){
                                self.$message({message:res.data.extra,type:'warning'});
                                setTimeout(function(){
                                    self.$router.replace('login');
                                },2000)
                            }
                            if(res.data.ret_code == 0){
                                self.showDialogPwd = false;
                                self.$message({message:res.data.extra,type:'success'})
                            }else{
                                self.$message.error(res.data.extra);
                            }
                        },function(err){
                            self.fullscreenLoading  = false;
                            self.$message.error(err);
                        })
                    }else {
                        console.log('error submit!!');
                        return false;
                    }
                })


            },
            toRouter: function(account){
                var self = this;
                self.showRouterDialog = true;
                self.curAccount2 = account;
                self.formMacfile.user_name = account;
            },
            delRouter: function(account){
                var self = this;
                self.showDelRouterDialog = true;
                self.curAccount3 = account;
                self.formMacfile.user_name3 = account;
            },
            outRouter: function(account){
                var self = this;
                var params = {
                    user_account: account
                };
                self.loading  = true;
                self.$axios.post(global_.baseUrl+'/device/export',params).then(function(res){
                    self.loading  = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        const aLink = document.createElement('a');
                        const evt = document.createEvent('MouseEvents');
                        // var evt = document.createEvent("HTMLEvents")
                        evt.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                        var str = res.data.extra;
                        var index = str.lastIndexOf("\/");
                        str  = str .substring(index + 1, str .length);
                        aLink.download = str;
                        aLink.href = global_.baseUrl+res.data.extra;
                        aLink.dispatchEvent(evt);
                        self.$message({message:'导出成功',type:'success'})
                    }else{
                        self.$message.error(res.data.extra);
                    }
                },function(err){
                    self.loading  = false;
                    self.$message.error(err);
                })
            },
            outClient: function(account) {
                var self = this;
                var params = {
                    user_account: account
                };
                self.loading  = true;
                self.$axios.post(global_.baseUrl+'/client/export',params).then(function(res){
                    self.loading  = false;
                    if(res.data.ret_code == '1001'){
                        self.$message({message:res.data.extra,type:'warning'});
                        setTimeout(function(){
                            self.$router.replace('login');
                        },2000)
                    }
                    if(res.data.ret_code == 0){
                        const aLink = document.createElement('a');
                        const evt = document.createEvent('MouseEvents');
                        // var evt = document.createEvent("HTMLEvents")
                        evt.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                        var str = res.data.extra;
                        var index = str.lastIndexOf("\/");
                        str  = str .substring(index + 1, str .length);
                        aLink.download = str;
                        aLink.href = global_.baseUrl+res.data.extra;
                        aLink.dispatchEvent(evt);
                        self.$message({message:'导出成功',type:'success'})
                    }else{
                        self.$message.error(res.data.extra);
                    }
                },function(err){
                    self.loading  = false;
                    self.$message.error(err);
                })
            },
            saveToRouterChange: function(formName){
                var self = this;
                self.$refs[formName].validate(function(valid){
                    if(valid){
                        var params = {
                            user_name:  self.curAccount2,
                            device_id:  self.formRouter2.device_id,
                            route_mac:  self.formRouter2.route_mac,
                            route_mac_once_auth:  self.formRouter2.route_mac_once_auth,
                            next_auth_time:  self.formRouter2.next_auth_time
                        };
                        self.loading2  = true;
                        self.$axios.post(global_.baseUrl+'/device/import',params).then(function(res){
                            self.loading2  = false;
                            if(res.data.ret_code == '1001'){
                                self.$message({message:res.data.extra,type:'warning'});
                                setTimeout(function(){
                                    self.$router.replace('login');
                                },2000)
                            }
                            if(res.data.ret_code == '1017'){
                                self.showRouterDialog = false;
                                var arr = res.data.extra;
                                var str = '';
                                if(arr.length > 3){
                                    var newarr = arr.slice(0,3);
                                    str = newarr.join(' / ')+'...';
                                }else{
                                    str = arr.join(' / ');
                                }
                                self.$message({message:'"'+ str +' "已存在',type:'warning'})
                            }
                            if(res.data.ret_code == 0){
                                self.showRouterDialog = false;
                                self.$message({message:'导入成功',type:'success'});
                                if(self.radio3 == 'all'){
                                    self.getUsers({page_size:10,current_page:self.currentPage},'all');
                                }else{
                                    self.getUsers({user_status:self.radio3,page_size:10,current_page:self.currentPage},'status');
                                }
                            }else{
                                self.$message.error(res.data.extra);
                            }
                        },function(err){
                            self.loading2  = false;
                            self.$message.error(err);
                        })
                    }else {
                        console.log('error submit!!');
                        return false;
                    }
                })
            },
            saveDelRouterChange: function(formName){
                var self = this;
                self.$refs[formName].validate(function(valid){
                    if(valid){
                        var params = {
                            user_name: self.curAccount3,
                            route_mac:self.formRouter3.route_mac
                        };
                        return false;
                        self.loading2  = true;
                        self.$axios.post(global_.baseUrl+'/device/import',params).then(function(res){
                            self.loading2  = false;
                            if(res.data.ret_code == '1001'){
                                self.$message({message:res.data.extra,type:'warning'});
                                setTimeout(function(){
                                    self.$router.replace('login');
                                },2000)
                            }
                            if(res.data.ret_code == '1017'){
                                self.showRouterDialog = false;
                                var arr = res.data.extra;
                                var str = '';
                                if(arr.length > 3){
                                    var newarr = arr.slice(0,3);
                                    str = newarr.join(' / ')+'...';
                                }else{
                                    str = arr.join(' / ');
                                }
                                self.$message({message:'"'+ str +' "已存在',type:'warning'})
                            }
                            if(res.data.ret_code == 0){
                                self.showRouterDialog = false;
                                self.$message({message:'导入成功',type:'success'});
                                if(self.radio3 == 'all'){
                                    self.getUsers({page_size:10,current_page:self.currentPage},'all');
                                }else{
                                    self.getUsers({user_status:self.radio3,page_size:10,current_page:self.currentPage},'status');
                                }
                            }else{
                                self.$message.error(res.data.extra);
                            }
                        },function(err){
                            self.loading2  = false;
                            self.$message.error(err);
                        })
                    }else {
                        console.log('error submit!!');
                        return false;
                    }
                })
            },
            validateRepwd: function(rule,value,callback){
                if(value !== this.formP.user_new_password){
                    callback(new Error('两次输入密码不一致'));
                }else{
                    callback();
                }
            },
            validateUser: function(rule,value,callback){
                if(value === ''){
                    callback(new Error('请输入账号'))
                }else{
                    callback();
                }
            },
            validatePwd: function(rule,value,callback){
                if(value === ''){
                    callback(new Error('请输入密码'))
                }else{
                    callback();
                }
            },
            validateTel:function(rule,value,callback){
                var regTel3 = /(\(\d{3,4}\)|\d{3,4}-|\s)?\d{7,14}$/.test(value);
                if(!regTel3){
                    callback(new Error('电话号码输入有误！'))
                }else{
                    callback();
                }
            },
            validateMac: function (rule, value, callback) {
                var self = this;
                var reg_name = /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
                var reg_name2 = /^[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}$/;
                var macarr = self.splitStr(value);
                for (var i = 0, len = macarr.length; i < len; i++) {
                    if (!reg_name.test(macarr[i]) && !reg_name2.test(macarr[i])) {
                        callback(new Error('输入有误，以逗号或回车分隔'));
                    } else {
                        callback();
                    }
                }
            },
            validateSpace: function (rule, value, callback) {
                var self = this;
                if(value.indexOf(' ')>=0){
                    callback(new Error('输入有空格'));
                }else{
                    callback();
                }
            },
            //按逗号和回车分隔字符串
            splitStr: function (str) {
                var temp = str.split(/[\n,]/g);
                for (var i = 0; i < temp.length; i++) {
                    if (temp[i] == "") {
                        temp.splice(i, 1);
                        //删除数组索引位置应保持不变
                        i--;
                    }
                }
                return temp;
            },
            handleClick:function(tab,event){

            },
            getProv: function(prov){
                let tempCity=[];
                this.citys=[];
                this.selectCity='';
                let allCity=global_.allCity;
                for (var val of allCity){
                    if (prov == val.prov){
                        console.log(val);
                        tempCity.push({label: val.label, value: val.label})
                    }
                }
                this.citys = tempCity;
            },
            getCity: function (city) {
                console.log(city);
                console.log(this.selectCity)
            },
            handleCurrentChange:function(val){
                this.currentPage = val;
                var url = this.radio3=='all'?'all':'status';
                var params = {};
                if(this.radio3 == 'all'){
                    params = {page_size:10,current_page:this.currentPage};
                }else{
                    params = {page_size:10,current_page:this.currentPage,user_status:this.radio3};
                }
                this.getUsers(params,url);
            },
            filterTag:function(value, row) {
                return row.user_status == value;
            },
            fileAdd: function(formName){
                var self = this;
                self.$refs.upload.submit();
            },
            beforeUpload: function(file){
                var testmsg=file.name.substring(file.name.lastIndexOf('.')+1);
                const extension = testmsg === 'xls';
                const extension2 = testmsg === 'xlsx';
                const extension3 = testmsg === 'doc';
                const extension4 = testmsg === 'docx';
                const isLt2M = file.size / 1024 / 1024 < 10;
                if (!extension && !extension2 && !extension3 && !extension4) {
                    this.$message({message:'上传模板只能是 xls格式!',type:'warning'});
                    return false;
                }
                if (!isLt2M) {
                    this.$message({message:'上传模板大小不能超过 10MB!',type:'warning'});
                    return false;
                }
                // else{
                //     return extension || extension2 || extension3 || extension4 && isLt2M;
                // }
            },
            handleSuccess: function(response,file,fileList){
                if(response.ret_code == '1017'){
                    this.showRouterDialog = false;
                    var arr = response.extra;
                    var str = '';
                    if(arr.length > 3){
                        var newarr = arr.slice(0,3);
                        str = newarr.join(' / ')+'...';
                    }else{
                        str = arr.join(' / ');
                    }
                    this.$message({message:'"'+ str +' "已存在',type:'warning'})
                }
                if(response.ret_code == 0){
                    this.$message({message:'创建成功',type:'success'});
                    if(self.radio3 == 'all'){
                        self.getUsers({page_size:10,current_page:self.currentPage},'all');
                    }else{
                        self.getUsers({user_status:self.radio3,page_size:10,current_page:self.currentPage},'status');
                    }
                }else{
                    this.$message.error(response.extra);
                }
                this.showRouterDialog = false;
            },
            handleError: function(response,file,fileList){
                this.$message.error('操作失败');
            },
            handleChange:function(file) {
                var self = this;
            },
        }
    }
</script>

<style scoped>
    .handle-box{  margin-bottom: 20px;  }
    .handle-select{  width: 120px;  }
    .handle-input{  width: 300px;  display: inline-block;  }
    .rad-group{margin-bottom:20px;}
    .btn1{margin-bottom:5px;margin-top:5px;/*margin-left:0;*/}
    /*.digcont{width:600px;}*/
    .diainp{width:217px;}
    .diainp2{width:400px;}
    .upload-demo{}
    .mb30{margin-bottom:30px;}
    .mt30{margin-top:30px;}
</style>
