<template>
    <div class="table" v-loading="loading2">
        <!-- User Management View (Super Admin) -->
        <div v-if="isUser === '0'">
            <div class="crumbs">
                <el-breadcrumb separator="/">
                    <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道管理</el-breadcrumb-item>
                    <el-breadcrumb-item>渠道列表</el-breadcrumb-item>
                </el-breadcrumb>
            </div>
            <el-form :inline="true" class="handle-box">
                <el-form-item>
                    <el-button type="primary" icon="plus" class="handle-del mr10" @click="openNewChannelDialog">新建子渠道</el-button>
                </el-form-item>
                <el-form-item label="">
                    <el-input v-model="search_word" placeholder="请输入渠道名称或账号查找" class="handle-input mr10"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" icon="search" @click="searchUsers">查询</el-button>
                </el-form-item>
            </el-form>
            <div class='rad-group'>
                <el-radio-group v-model="userStatusFilter" @change="handleUserStatusFilterChange">
                    <el-radio-button label="all">全部</el-radio-button>
                    <el-radio-button label="0">未冻结</el-radio-button>
                    <el-radio-button label="1">已冻结</el-radio-button>
                </el-radio-group>
            </div>
            <el-table :data="userData" border style="width: 100%" ref="multipleTable" :empty-text="emptyMsg" v-loading="loading">
                <el-table-column prop="userAccount" label="账 号" width="150"></el-table-column>
                <el-table-column prop="userName" label="渠道名称"></el-table-column>
                <el-table-column prop="userPhone" label="联系电话" width="130"></el-table-column>
                <el-table-column prop="userStatus" label="冻结状态" width="120">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.userStatus == '1' ? 'warning' : 'success'" close-transition>{{scope.row.userStatus=='1'?'已冻结':'未冻结'}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="渠道类型" width="120">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.userType == '0' ? 'danger' : 'info'" close-transition>{{scope.row.userType == '0'?'超级管理员':'管理员'}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="userCreateTime" label="创建时间" width="150"></el-table-column>
                <el-table-column label="在线设备" width="100">
                    <template slot-scope="scope">
                        <el-tag type="warning">{{scope.row.userOnlineCount + '/ ' + scope.row.userDeviceCount}}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="380">
                    <template slot-scope="scope">
                        <el-button class="btn1" size="small" type="text" @click="adminResetPassword(scope.row.userAccount)">重置密码</el-button>
                        <el-button class="btn1" size="small" v-if="scope.row.userStatus =='0' && scope.row.userType =='1'" @click="freezeUserAccount(scope.row.userAccount)" :type="scope.row.userStatus == '1' ? 'warning' : 'danger'">冻结账户</el-button>
                        <el-button class="btn1" size="small" v-else-if="scope.row.userStatus =='1' && scope.row.userType =='1'" @click="unfreezeUserAccount(scope.row.userAccount)" :type="scope.row.userStatus == '1' ? 'warning' : 'danger'">解冻账户</el-button>
                        <el-button class="btn1" size="small" v-if="scope.row.userType =='1'?true:false" type="success" @click="switchToChannelView(scope.row.userAccount)">点击进入</el-button>
                         <el-button class="btn1" size="small" type="text" @click="openChangePasswordDialogForUser(scope.row.userAccount)">修改密码</el-button>
                         <el-button class="btn1" size="small" type="text" @click="openImportRouterDialogForUser(scope.row.userAccount)">导入路由</el-button>
                         <el-button class="btn1" size="small" type="text" @click="openDeleteRouterDialogForUser(scope.row.userAccount)">删除路由</el-button>
                    </template>
                </el-table-column>
            </el-table>
            <div class="pagination">
                <el-pagination
                    @current-change ="handleTablePageChange"
                    :current-page="currentPage"
                    layout="prev, pager, next"
                    :total="pageTotal">
                </el-pagination>
            </div>
        </div>

        <div v-if="isUser === '1'">
            <div class="crumbs">
                <el-breadcrumb separator="/">
                    <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道设备</el-breadcrumb-item>
                    <el-breadcrumb-item>认证设备</el-breadcrumb-item>
                </el-breadcrumb>
            </div>
            <el-form :inline="true" class="handle-box">
                <el-form-item>
                    <el-button type="primary" icon="plus" class="handle-del mr10" @click="openAddGatewayDialog">添加认证网关设备</el-button>
                </el-form-item>
            </el-form>
            <div v-if="gatewayData.length === 0" class="no-device">no device available</div>
            <el-table v-else :data="gatewayData" border style="width: 100%" ref="gatewayTable">
                <el-table-column prop="gwChannel" label="渠道"></el-table-column>
                <el-table-column prop="deviceID" label="设备ID"></el-table-column>
                <el-table-column prop="gwID" label="网关ID"></el-table-column>
                <el-table-column prop="onceAuth" label="单次认证网关ID">
                    <template slot-scope="scope">
                        <el-switch v-model="scope.row.onceAuth" active-color="#13ce66" inactive-color="#ff4949" @change="updateGatewayAuthStatus(scope.row)"></el-switch>
                    </template>
                </el-table-column>
                <el-table-column prop="nextAuthTime" label="单次认证免认证时长"></el-table-column>
                <el-table-column label="操作">
                    <template slot-scope="scope">
                        <el-button class="btn1" size="small" type="danger" @click="deleteGateway(scope.row.deviceID, scope.row.gwID)">删除网关</el-button>
                        <el-button class="btn1" size="small" type="primary" @click="openUpdateGatewayDialog(scope.row)">更新网关</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>

        <new-channel-dialog
            :visible.sync="dialogs.newChannel.visible"
            :form-label-width="formLabelWidth"
            :initial-provs="dialogs.newChannel.provs"
            @save="handleSaveNewChannel"
            @close="dialogs.newChannel.visible = false"
            ref="newChannelDialogRef"
        ></new-channel-dialog>

        <change-password-dialog
            :visible.sync="dialogs.changePassword.visible"
            :form-label-width="formLabelWidth"
            :target-account="dialogs.changePassword.currentAccount"
            @save="handleSavePasswordChange"
            @close="dialogs.changePassword.visible = false"
            ref="changePasswordDialogRef"
        ></change-password-dialog>

        <add-update-gateway-dialog
            :visible.sync="dialogs.addUpdateGateway.visible"
            :form-label-width="formLabelWidth"
            :is-update="dialogs.addUpdateGateway.isUpdate"
            :initial-data="dialogs.addUpdateGateway.form"
            @save="handleSaveGateway"
            @close="dialogs.addUpdateGateway.visible = false"
            ref="addUpdateGatewayDialogRef"
        ></add-update-gateway-dialog>

        <import-router-dialog
            :visible.sync="dialogs.importRouter.visible"
            :form-label-width="formLabelWidth"
            :target-account="dialogs.importRouter.currentAccount"
            :upload-url-prop="dialogs.importRouter.uploadUrl"
            @upload-success="handleImportRouterUploadSuccess"
            @upload-error="handleImportRouterUploadError"
            @manual-save="handleImportRouterManualSave"
            @close="dialogs.importRouter.visible = false"
            ref="importRouterDialogRef"
        ></import-router-dialog>

        <delete-router-dialog
            :visible.sync="dialogs.deleteRouter.visible"
            :target-account="dialogs.deleteRouter.currentAccount"
            @save="handleDeleteRouterSave"
            @close="dialogs.deleteRouter.visible = false"
            ref="deleteRouterDialogRef"
        ></delete-router-dialog>
    </div>
</template>

<script>
    import md5 from 'js-md5';
    import global_ from 'components/common/Global';

    // Import Dialog Components
    import NewChannelDialog from '@/components/dialogs/NewChannelDialog.vue';
    import ChangePasswordDialog from '@/components/dialogs/ChangePasswordDialog.vue';
    import AddUpdateGatewayDialog from '@/components/dialogs/AddUpdateGatewayDialog.vue';
    import ImportRouterDialog from '@/components/dialogs/ImportRouterDialog.vue';
    import DeleteRouterDialog from '@/components/dialogs/DeleteRouterDialog.vue';

    export default {
        name: 'BaseTable',
        components: {
            NewChannelDialog,
            ChangePasswordDialog,
            AddUpdateGatewayDialog,
            ImportRouterDialog,
            DeleteRouterDialog,
        },
        data: function() {
            return {
                // General Page State & User Type
                isUser: localStorage.getItem('userType') || '0',
                loading: false,
                loading2: false,
                fullscreenLoading: false,

                // User (Channel) Management
                userData: [],
                search_word: '',
                userStatusFilter: 'all',

                // Device/Gateway Management (for channel admin view)
                gatewayData: [],

                // Table & Pagination
                pageTotal: 0,
                currentPage: 1,
                emptyMsg: '暂无数据',

                formLabelWidth: '120px',

                dialogs: {
                    newChannel: {
                        visible: false,
                        provs: global_.provs || [],
                    },
                    changePassword: {
                        visible: false,
                        currentAccount: '',
                    },
                    addUpdateGateway: {
                        visible: false,
                        isUpdate: false,
                        form: {
                            device_id: '',
                            gw_id: '',
                            once_auth: false,
                            next_auth_time: ''
                        },
                    },
                    importRouter: {
                        visible: false,
                        currentAccount: '',
                        uploadUrl: global_.baseUrl + '/device/import/excel',
                    },
                    deleteRouter: {
                        visible: false,
                        currentAccount: '',
                    }
                },
            }
        },

        created: function() {
            if (this.isUser === '1') {
                this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
            } else {
                this.fetchUsers({ page_size: 10, current_page: this.currentPage }, 'all');
            }
        },

        methods: {
            handleApiError: function(message, redirectToLogin = false) {
                this.$message({ message: message || '操作失败，请稍后再试', type: 'warning' });
                if (redirectToLogin) {
                    setTimeout(() => this.$router.replace('login'), 2000);
                }
            },
            fetchUsers: function(params, endpoint) {
                this.loading = true;
                this.$axios.post(global_.baseUrl + '/admin/' + endpoint, params).then(res => {
                    this.loading = false;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                    } else if (res.data.ret_code === '1010') {
                        this.emptyMsg = res.data.extra;
                        this.userData = []; this.pageTotal = 0;
                    } else if (res.data.ret_code === 0) {
                        const extraData = res.data.extra;
                        this.pageTotal = extraData.count || this.pageTotal;
                        this.userData = extraData.allAdmin || [];
                         if (endpoint === 'query' && res.data.data) {
                            this.userData = res.data.data;
                            this.pageTotal = res.data.data.length;
                        }
                    } else {
                         this.handleApiError(res.data.extra);
                         this.userData = []; this.pageTotal = 0;
                    }
                }).catch(err => {
                    this.loading = false; this.handleApiError('请求用户列表失败: ' + err.message);
                    this.userData = []; this.pageTotal = 0;
                });
            },
            fetchGatewayDataForChannel: function(gw_channel) {
                this.loading2 = true;
                const params = { gw_channel: gw_channel };
                this.$axios.post(global_.baseUrl + '/device/queryGateway', params).then(res => {
                    this.loading2 = false;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                    } else if (res.data.ret_code === 0) {
                        this.gatewayData = res.data.extra;
                    } else {
                        this.handleApiError(res.data.extra); this.gatewayData = [];
                    }
                }).catch(err => {
                    this.loading2 = false; this.handleApiError('请求网关数据失败: ' + err.message);
                    this.gatewayData = [];
                });
            },
            handleUserStatusFilterChange: function() {
                this.currentPage = 1;
                const params = { page_size: 10, current_page: this.currentPage };
                if (this.userStatusFilter !== 'all') {
                    params.user_status = this.userStatusFilter;
                }
                this.fetchUsers(params, this.userStatusFilter === 'all' ? 'all' : 'status');
            },
            searchUsers: function() {
                if (!this.search_word.trim()) {
                    this.$message({ message: '输入不能为空', type: 'warning' }); return;
                }
                this.currentPage = 1;
                this.fetchUsers({ user: this.search_word, page_size:10, current_page: this.currentPage }, 'query');
            },
            openNewChannelDialog: function() {
                this.dialogs.newChannel.visible = true;
            },
            handleSaveNewChannel: function(formData) {
                const params = {
                    user_account: formData.user,
                    user_password: md5(formData.password),
                    user_name: formData.name,
                    user_phone: formData.tel,
                    user_city: formData.selectProv + formData.selectCity + formData.addr
                };
                this.$axios.post(global_.baseUrl + '/admin/register', params).then(res => {
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                        if(this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
                    } else if (res.data.ret_code === 0) {
                        this.$message({ message: '注册成功！', type: 'success' });
                        if(this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveSuccess();
                        this.userStatusFilter = 'all';
                        this.fetchUsers({ page_size: 10, current_page: 1 }, 'all');
                    } else {
                        this.handleApiError(res.data.extra || '创建渠道失败');
                        if(this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
                    }
                }).catch(err => {
                     this.handleApiError('创建渠道请求失败: ' + err.message);
                     if(this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
                });
            },
            freezeUserAccount: function(account) {
                this.performUserStatusUpdate(account, '/admin/revoke', '冻结');
            },
            unfreezeUserAccount: function(account) {
                this.performUserStatusUpdate(account, '/admin/restore', '解冻');
            },
            performUserStatusUpdate: function(account, urlPath, actionName) {
                this.loading = true;
                this.$axios.post(global_.baseUrl + urlPath, { user_account: account }).then(res => {
                    this.loading = false;
                    if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
                    else if (res.data.ret_code === 0) {
                        this.$message({ message: res.data.extra || `${actionName}成功`, type: 'success' });
                        this.handleUserStatusFilterChange();
                    } else this.handleApiError(res.data.extra || `${actionName}失败`);
                }).catch(err => { this.loading = false; this.handleApiError(`${actionName}操作失败: ` + err.message); });
            },
            switchToChannelView: function(userAccount) {
                this.loading = true;
                this.$axios.post(global_.baseUrl + '/admin/switch', { user_account: userAccount }).then(res => {
                    this.loading = false;
                    if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
                    else if (res.data.ret_code === 0) {
                        this.$message({ message: res.data.extra || '切换成功', type: 'success' });
                        localStorage.setItem('ms_username', userAccount);
                        localStorage.setItem('userType', '1');
                        window.location.reload();
                    } else this.handleApiError(res.data.extra || '切换失败');
                }).catch(err => { this.loading = false; this.handleApiError('切换渠道请求失败: ' + err.message);});
            },
            openChangePasswordDialogForUser: function(account) {
                this.dialogs.changePassword.currentAccount = account;
                this.dialogs.changePassword.visible = true;
            },
            adminResetPassword: function(account) {
                this.loading = true;
                this.$axios.post(global_.baseUrl + '/admin/reset', { user_account: account }).then(res => {
                    this.loading = false;
                    if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
                    else if (res.data.ret_code === 0) this.$message({ message: res.data.extra || '密码重置成功', type: 'success' });
                    else this.handleApiError(res.data.extra || '密码重置失败');
                }).catch(err => { this.loading = false; this.handleApiError('密码重置请求失败: ' + err.message);});
            },
            handleSavePasswordChange: function(formData) {
                this.fullscreenLoading = true;
                this.$axios.post(global_.baseUrl + '/admin/change', formData).then(res => {
                    this.fullscreenLoading = false;
                    const dialogRef = this.$refs.changePasswordDialogRef;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                        if(dialogRef) dialogRef.onSaveError();
                    } else if (res.data.ret_code === 0) {
                        this.$message({ message: res.data.extra || '密码修改成功', type: 'success' });
                        if(dialogRef) dialogRef.onSaveSuccess();
                    } else {
                        this.handleApiError(res.data.extra || '密码修改失败');
                        if(dialogRef) dialogRef.onSaveError();
                    }
                }).catch(err => {
                    this.fullscreenLoading = false; this.handleApiError('密码修改请求失败: ' + err.message);
                    if(this.$refs.changePasswordDialogRef) this.$refs.changePasswordDialogRef.onSaveError();
                });
            },
            openAddGatewayDialog: function() {
                const dlg = this.dialogs.addUpdateGateway;
                dlg.isUpdate = false;
                dlg.form = {
                    user_account: localStorage.getItem('ms_username'),
                    gw_channel: localStorage.getItem('ms_username'),
                    device_id: '', gw_id: '', once_auth: false, next_auth_time: ''
                };
                dlg.visible = true;
            },
            openUpdateGatewayDialog: function(gatewayRowData) {
                const dlg = this.dialogs.addUpdateGateway;
                dlg.isUpdate = true;
                dlg.form = {
                    ...gatewayRowData,
                    user_account: localStorage.getItem('ms_username'),
                    gw_channel: localStorage.getItem('ms_username'),
                };
                dlg.visible = true;
            },
            handleSaveGateway: function(formData, isUpdateFlag) {
                const params = { ...formData };
                this.$axios.post(global_.baseUrl + '/device/updateGateway', params).then(res => {
                    const dialogRef = this.$refs.addUpdateGatewayDialogRef;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                        if (dialogRef) dialogRef.onSaveError();
                    } else if (res.data.ret_code === 0) {
                        this.$message({ message: (isUpdateFlag ? '修改' : '添加') + '成功', type: 'success' });
                        this.fetchGatewayDataForChannel(params.gw_channel || localStorage.getItem('ms_username'));
                        if (dialogRef) dialogRef.onSaveSuccess();
                    } else {
                        this.handleApiError(res.data.extra || '操作失败');
                        if (dialogRef) dialogRef.onSaveError();
                    }
                }).catch(err => {
                    this.handleApiError('网关操作请求失败: ' + err.message);
                    if (this.$refs.addUpdateGatewayDialogRef) this.$refs.addUpdateGatewayDialogRef.onSaveError();
                });
            },
            updateGatewayAuthStatus: function(gatewayRow) {
                const params = {
                    device_id: gatewayRow.deviceID, gw_id: gatewayRow.gwID,
                    once_auth: gatewayRow.onceAuth, next_auth_time: gatewayRow.nextAuthTime,
                    user_account: localStorage.getItem('ms_username'),
                    gw_channel: localStorage.getItem('ms_username'),
                };
                this.loading2 = true;
                this.$axios.post(global_.baseUrl + '/device/updateGateway', params).then(res => {
                    this.loading2 = false;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                    } else if (res.data.ret_code === 0) {
                        this.$message({ message: '认证状态更新成功', type: 'success' });
                    } else {
                        this.handleApiError(res.data.extra || '更新失败');
                    }
                    this.fetchGatewayDataForChannel(localStorage.getItem('ms_username')); // Refresh state
                }).catch(err => {
                    this.loading2 = false; this.handleApiError('认证状态更新请求失败: ' + err.message);
                    this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
                });
            },
            deleteGateway: function(device_id, gw_id) {
                this.$confirm('此操作将删除该网关, 是否继续?', '提示', { type: 'warning' })
                .then(() => {
                    const params = { device_id: device_id, gw_id: gw_id, user_account: localStorage.getItem('ms_username'), gw_channel: localStorage.getItem('ms_username') };
                    this.$axios.post(global_.baseUrl + '/device/deleteGateway', params).then(res => {
                        if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
                        else if (res.data.ret_code === 0) {
                            this.$message({ message: '删除成功', type: 'success' });
                            this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
                        } else this.handleApiError(res.data.extra || '删除失败');
                    }).catch(err => this.handleApiError('删除网关请求失败: ' + err.message));
                }).catch(() => this.$message({ type: 'info', message: '已取消删除' }));
            },
            openImportRouterDialogForUser: function(account) {
                this.dialogs.importRouter.currentAccount = account;
                this.dialogs.importRouter.visible = true;
            },
            handleImportRouterUploadSuccess: function(response) {
                const dialogRef = this.$refs.importRouterDialogRef;
                if (response.ret_code === '1017') {
                    let arr = response.extra;
                    let str = arr.length > 3 ? arr.slice(0, 3).join(' / ') + '...' : arr.join(' / ');
                    this.$message({ message: `"${str}" 已存在`, type: 'warning' });
                     if (dialogRef) dialogRef.onUploadFinished(false);
                } else if (response.ret_code === 0) {
                    this.$message({ message: '文件导入成功', type: 'success' });
                    this.handleUserStatusFilterChange();
                    if (dialogRef) dialogRef.onUploadFinished(true);
                } else {
                    this.handleApiError(response.extra || '文件导入失败');
                    if (dialogRef) dialogRef.onUploadFinished(false);
                }
            },
            handleImportRouterUploadError: function(err) {
                this.handleApiError('文件上传失败: ' + (err.message || '未知错误'));
                if (this.$refs.importRouterDialogRef) this.$refs.importRouterDialogRef.onUploadFinished(false);
            },
            handleImportRouterManualSave: function(formData) {
                this.loading2 = true;
                const dialogRef = this.$refs.importRouterDialogRef;
                this.$axios.post(global_.baseUrl + '/device/import', formData).then(res => {
                    this.loading2 = false;
                    if (res.data.ret_code === '1001') {
                        this.handleApiError(res.data.extra, true);
                        if (dialogRef) dialogRef.onSaveManualError();
                    } else if (res.data.ret_code === '1017') {
                        let arr = res.data.extra;
                        let str = arr.length > 3 ? arr.slice(0, 3).join(' / ') + '...' : arr.join(' / ');
                        this.$message({ message: `"${str}" 已存在`, type: 'warning' });
                         if (dialogRef) dialogRef.onSaveManualError();
                    } else if (res.data.ret_code === 0) {
                        this.$message({ message: '导入成功', type: 'success' });
                        this.handleUserStatusFilterChange();
                        if (dialogRef) dialogRef.onSaveManualSuccess();
                    } else {
                        this.handleApiError(res.data.extra || '手动导入路由失败');
                        if (dialogRef) dialogRef.onSaveManualError();
                    }
                }).catch(err => {
                    this.loading2 = false; this.handleApiError('手动导入路由请求失败: ' + err.message);
                    if (dialogRef) dialogRef.onSaveManualError();
                });
            },
            openDeleteRouterDialogForUser: function(account) {
                this.dialogs.deleteRouter.currentAccount = account;
                this.dialogs.deleteRouter.visible = true;
            },
            handleDeleteRouterSave: function(formData) {
                this.$message.warning('删除路由功能API端点未确定，请联系后端开发。');
                console.warn("Attempted to delete router with data:", formData, "but API endpoint is not specified or incorrect.");
                if (this.$refs.deleteRouterDialogRef) {
                    this.$refs.deleteRouterDialogRef.onSaveError();
                }
            },
            exportRouters: function(account) { this.performExport(account, '/device/export', '路由器'); },
            exportClients: function(account) { this.performExport(account, '/client/export', '客户端'); },
            performExport: function(account, urlPath, exportType) {
                this.loading = true;
                this.$axios.post(global_.baseUrl + urlPath, { user_account: account }).then(res => {
                    this.loading = false;
                    if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
                    else if (res.data.ret_code === 0) {
                        const filePath = res.data.extra;
                        const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
                        const link = document.createElement('a');
                        link.href = global_.baseUrl + filePath; link.download = fileName;
                        document.body.appendChild(link); link.click(); document.body.removeChild(link);
                        this.$message({ message: `${exportType}导出成功`, type: 'success' });
                    } else this.handleApiError(res.data.extra || `${exportType}导出失败`);
                }).catch(err => { this.loading = false; this.handleApiError(`${exportType}导出请求失败: ` + err.message);});
            },
            handleTablePageChange: function(newPage) {
                this.currentPage = newPage;
                const params = { page_size: 10, current_page: this.currentPage };
                if (this.search_word) {
                     params.user = this.search_word;
                     this.fetchUsers(params, 'query');
                } else if (this.userStatusFilter === 'all') {
                    this.fetchUsers(params, 'all');
                } else {
                    params.user_status = this.userStatusFilter;
                    this.fetchUsers(params, 'status');
                }
            },
            filterUserStatusTag: function(value, row) {
                return row.userStatus == value;
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
    /*.digcont{width:600px;}*/ /* This was commented out, good to keep as is or remove */
    .diainp{width:217px;}
    .diainp2{width:400px;}
    .upload-demo{}
    .mb30{margin-bottom:30px;}
    .mt30{margin-top:30px;}
    .no-device{ /* Added this from inspection of original template if needed */
        padding: 20px;
        text-align: center;
        color: #888;
    }
    .form-item-center .el-form-item__content { /* For AddUpdateGatewayDialog specific style if needed, though this is broad */
        /* text-align: center; */ /* Example, if it was meant to center the input itself */
    }

</style>
