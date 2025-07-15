<template>
  <div>
    <!-- 页面容器 -->
    <div class="container">
      <!-- 用户管理视图 (超级管理员) -->
      <div v-if="isUser === '0'">
        <!-- 面包屑导航 -->
        <div class="bread-crumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道管理</el-breadcrumb-item>
            <el-breadcrumb-item>渠道列表</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <!-- 筛选和搜索区域 -->
        <div>
          <el-radio-group v-model="userStatusFilter" @change="handleUserStatusFilterChange">
            <el-radio-button label="all">全部</el-radio-button>
            <el-radio-button label="0">未冻结</el-radio-button>
            <el-radio-button label="1">已冻结</el-radio-button>
          </el-radio-group>

          <el-form :inline="true" style="float: right">
            <el-form-item>
              <el-input v-model="search_word" placeholder="请输入渠道名称或账号查找" clearable>
                <template #append>
                  <el-button type="primary" icon="search" @click="searchUsers">
                    <i class="el-icon-search"></i>
                  </el-button>
                </template>
              </el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="plus" @click="openNewChannelDialog"> <i class="el-icon-plus"></i>新建子渠道 </el-button>
            </el-form-item>
          </el-form>
        </div>

        <!-- 表格内容区域 -->
        <div class="overflow-hidden rounded-lg shadow-sm border border-gray-200">
          <el-table :data="userData" stripe style="width: 100%" ref="multipleTable" :empty-text="emptyMsg" v-loading="loading" class="min-w-full">
            <el-table-column prop="userAccount" label="账 号"></el-table-column>
            <el-table-column prop="userName" label="渠道名称"></el-table-column>
            <el-table-column prop="userPhone" label="联系电话"></el-table-column>
            <el-table-column prop="userStatus" label="冻结状态">
              <template slot-scope="scope">
                <el-tag :type="scope.row.userStatus == '1' ? 'warning' : 'success'" close-transition>{{ scope.row.userStatus == '1' ? '已冻结' : '未冻结' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="渠道类型">
              <template slot-scope="scope">
                <el-tag :type="scope.row.userType == '0' ? 'danger' : 'info'" close-transition>{{ scope.row.userType == '0' ? '超级管理员' : '管理员' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="userCreateTime" label="创建时间" width="150"></el-table-column>
            <el-table-column label="在线设备">
              <template slot-scope="scope">
                <el-tag type="warning">{{ scope.row.userOnlineCount + '/ ' + scope.row.userDeviceCount }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" min-width="100">
              <template slot-scope="scope">
                <div class="flex flex-wrap gap-1">
                  <el-button size="small" type="text" @click="adminResetPassword(scope.row.userAccount)">重置密码</el-button>
                  <el-button size="small" type="text" @click="openChangePasswordDialogForUser(scope.row.userAccount)">修改密码</el-button>

                  <el-dropdown style="margin-left: 10px">
                    <el-button size="small" type="text">更多...</el-button>
                    <el-dropdown-menu slot="dropdown">
                      <el-dropdown-item>
                        <el-button size="small" v-if="scope.row.userType == '1' ? true : false" type="success" @click="switchToChannelView(scope.row.userAccount)"
                          >点击进入</el-button
                        ></el-dropdown-item
                      >
                      <el-dropdown-item>
                        <el-button
                          size="mini"
                          v-if="scope.row.userStatus == '0' && scope.row.userType == '1'"
                          @click="freezeUserAccount(scope.row.userAccount)"
                          :type="scope.row.userStatus == '1' ? 'warning' : 'danger'"
                          >冻结账户</el-button
                        >
                        <el-button size="mini" v-else @click="unfreezeUserAccount(scope.row.userAccount)" :type="scope.row.userStatus == '1' ? 'warning' : 'danger'">解冻账户</el-button>
                      </el-dropdown-item>
                      <el-dropdown-item> <el-button size="small" type="primary" @click="openImportRouterDialogForUser(scope.row.userAccount)">导入路由</el-button> </el-dropdown-item>
                      <el-dropdown-item>
                        <el-button size="small" type="danger" @click="openDeleteRouterDialogForUser(scope.row.userAccount)">删除路由</el-button>
                      </el-dropdown-item>
                      <el-dropdown-item>
                        <el-button size="small" type="danger" @click="deleteChannel(scope.row.userAccount)" v-if="scope.row.userAccount != 'admin'">删除账户</el-button>
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </el-dropdown>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 分页区域 -->
        <div class="mt-6 flex justify-center">
          <el-pagination @current-change="handleTablePageChange" :current-page="currentPage" layout="prev, pager, next" :total="pageTotal" class="bg-white p-3 rounded-lg shadow-sm"></el-pagination>
        </div>
      </div>

      <!-- 渠道设备视图 (渠道管理员) -->
      <div v-if="isUser === '1'">
        <!-- 面包屑导航 -->
        <div class="bread-crumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item><i class="el-icon-menu"></i> 渠道设备</el-breadcrumb-item>
            <el-breadcrumb-item>认证设备</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <el-table :data="gatewayData" stripe style="width: 100%" ref="gatewayTable">
          <el-table-column label="渠道">
            <template slot-scope="scope">
              <span>{{ scope.row.gwChannel }}</span>
            </template>
          </el-table-column>
          <el-table-column label="设备ID" width="220">
            <template slot-scope="scope">
              <el-input v-if="scope.row.isEditing || scope.row.isNew" v-model="scope.row.deviceID" size="small" placeholder="请输入设备ID"></el-input>
              <span v-else>{{ scope.row.deviceID }}</span>
            </template>
          </el-table-column>
          <el-table-column label="网关ID" width="150">
            <template slot-scope="scope">
              <el-input v-if="scope.row.isEditing || scope.row.isNew" v-model="scope.row.gwID" size="small" placeholder="请输入网关ID"></el-input>
              <span v-else>{{ scope.row.gwID }}</span>
            </template>
          </el-table-column>
          <el-table-column label="开启单次认证">
            <template slot-scope="scope">
              <el-switch v-model="scope.row.onceAuth" @change="updateGatewayAuthStatus(scope.row)" class="transform scale-90"></el-switch>
            </template>
          </el-table-column>
          <el-table-column label="单次认证免认证时长">
            <template slot-scope="scope">
              <el-input v-if="scope.row.isEditing || scope.row.isNew" v-model="scope.row.nextAuthTime" size="small" placeholder="请输入免认证时长" :disabled="!scope.row.onceAuth"> </el-input>
              <span v-else>{{ scope.row.nextAuthTime }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作">
            <template slot-scope="scope">
              <div class="flex flex-wrap gap-1">
                <el-button size="small" type="danger" v-if="!scope.row.isNew && !scope.row.isEditing" @click="deleteGateway(scope.row.deviceID, scope.row.gwID)">删除网关</el-button>
                <el-button size="small" type="primary" v-if="!scope.row.isNew && !scope.row.isEditing" @click="toggleEditGateway(scope.row)">
                  {{ '编辑' }}
                </el-button>
                <el-button size="small" type="success" v-if="scope.row.isEditing || scope.row.isNew" @click="saveGateway(scope.row)">保存网关</el-button>
                <el-button size="small" type="warning" v-if="scope.row.isEditing || scope.row.isNew" @click="cancelEditGateway(scope.row)">取消</el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <!-- 添加网关按钮 -->
        <div style="margin-top: 10px">
          <el-button type="primary" icon="plus" size="small" @click="addNewGatewayRow"> <i class="el-icon-plus mr-2"></i>添加认证网关设备 </el-button>
        </div>
      </div>
    </div>

    <!-- 对话框组件 -->
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

    <import-router-dialog
      :visible.sync="dialogs.importRouter.visible"
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

// 导入对话框组件
import NewChannelDialog from '@/components/dialogs/NewChannelDialog.vue';
import ChangePasswordDialog from '@/components/dialogs/ChangePasswordDialog.vue';
import ImportRouterDialog from '@/components/dialogs/ImportRouterDialog.vue';
import DeleteRouterDialog from '@/components/dialogs/DeleteRouterDialog.vue';

export default {
  name: 'BaseTable',
  components: {
    NewChannelDialog,
    ChangePasswordDialog,
    ImportRouterDialog,
    DeleteRouterDialog
  },
  data: function () {
    return {
      // 通用页面状态和用户类型
      isUser: localStorage.getItem('userType') || '0',
      loading: false,
      loading2: false,
      fullscreenLoading: false,

      // 用户(渠道)管理
      userData: [],
      search_word: '',
      userStatusFilter: 'all',

      // 设备/网关管理(渠道管理员视图)
      gatewayData: [],
      showNewGatewayRow: false,

      // 表格和分页
      pageTotal: 0,
      currentPage: 1,
      emptyMsg: '暂无数据',

      formLabelWidth: '120px',

      dialogs: {
        newChannel: {
          visible: false,
          provs: global_.provs || []
        },
        changePassword: {
          visible: false,
          currentAccount: ''
        },
        importRouter: {
          visible: false,
          currentAccount: '',
          uploadUrl: global_.baseUrl + '/device/import/excel'
        },
        deleteRouter: {
          visible: false,
          currentAccount: ''
        }
      }
    };
  },

  created: function () {
    if (this.isUser === '1') {
      this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
    } else {
      this.fetchUsers({ page_size: 10, current_page: this.currentPage }, 'all');
    }
  },

  methods: {
    handleApiError: function (message, redirectToLogin = false) {
      this.$message({ message: message || '操作失败，请稍后再试', type: 'warning' });
      if (redirectToLogin) {
        setTimeout(() => this.$router.replace('login'), 2000);
      }
    },
    fetchUsers: function (params, endpoint) {
      this.loading = true;
      this.$axios
        .post(global_.baseUrl + '/admin/' + endpoint, params)
        .then(res => {
          this.loading = false;
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
          } else if (res.data.ret_code === '1010') {
            this.emptyMsg = res.data.extra;
            this.userData = [];
            this.pageTotal = 0;
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
            this.userData = [];
            this.pageTotal = 0;
          }
        })
        .catch(err => {
          this.loading = false;
          this.handleApiError('请求用户列表失败: ' + err.message);
          this.userData = [];
          this.pageTotal = 0;
        });
    },
    fetchGatewayDataForChannel: function (gw_channel) {
      this.loading2 = true;
      const params = { gw_channel: gw_channel };
      this.$axios
        .post(global_.baseUrl + '/device/queryGateway', params)
        .then(res => {
          this.loading2 = false;
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
          } else if (res.data.ret_code === 0) {
            this.gatewayData = res.data.extra || [];
            // 确保数据中有isEditing和isNew字段
            this.gatewayData.forEach(item => {
              // 使用Vue.set确保属性是响应式的
              this.$set(item, 'isEditing', false);
              this.$set(item, 'isNew', false);
            });
          } else {
            this.handleApiError(res.data.extra);
            this.gatewayData = [];
          }
        })
        .catch(err => {
          this.loading2 = false;
          this.handleApiError('请求网关数据失败: ' + err.message);
          this.gatewayData = [];
        });
    },
    handleUserStatusFilterChange: function () {
      this.currentPage = 1;
      const params = { page_size: 10, current_page: this.currentPage };
      if (this.userStatusFilter !== 'all') {
        params.user_status = this.userStatusFilter;
      }
      this.fetchUsers(params, this.userStatusFilter === 'all' ? 'all' : 'status');
    },
    searchUsers: function () {
      if (!this.search_word.trim()) {
        this.$message({ message: '输入不能为空', type: 'warning' });
        return;
      }
      this.currentPage = 1;
      this.fetchUsers({ user: this.search_word, page_size: 10, current_page: this.currentPage }, 'query');
    },
    openNewChannelDialog: function () {
      this.dialogs.newChannel.visible = true;
    },
    handleSaveNewChannel: function (formData) {
      const params = {
        user_account: formData.user,
        user_password: md5(formData.password),
        user_name: formData.name,
        user_phone: formData.tel,
        user_city: formData.selectProv + formData.selectCity + formData.addr
      };
      this.$axios
        .post(global_.baseUrl + '/admin/register', params)
        .then(res => {
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
            if (this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
          } else if (res.data.ret_code === 0) {
            this.$message({ message: '注册成功！', type: 'success' });
            if (this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveSuccess();
            this.userStatusFilter = 'all';
            this.fetchUsers({ page_size: 10, current_page: 1 }, 'all');
          } else {
            this.handleApiError(res.data.extra || '创建渠道失败');
            if (this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
          }
        })
        .catch(err => {
          this.handleApiError('创建渠道请求失败: ' + err.message);
          if (this.$refs.newChannelDialogRef) this.$refs.newChannelDialogRef.onSaveError();
        });
    },
    freezeUserAccount: function (account) {
      this.performUserStatusUpdate(account, '/admin/revoke', '冻结');
    },
    unfreezeUserAccount: function (account) {
      this.performUserStatusUpdate(account, '/admin/restore', '解冻');
    },
    performUserStatusUpdate: function (account, urlPath, actionName) {
      this.loading = true;
      this.$axios
        .post(global_.baseUrl + urlPath, { user_account: account })
        .then(res => {
          this.loading = false;
          if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
          else if (res.data.ret_code === 0) {
            this.$message({ message: res.data.extra || `${actionName}成功`, type: 'success' });
            this.handleUserStatusFilterChange();
          } else this.handleApiError(res.data.extra || `${actionName}失败`);
        })
        .catch(err => {
          this.loading = false;
          this.handleApiError(`${actionName}操作失败: ` + err.message);
        });
    },
    switchToChannelView: function (userAccount) {
      this.loading = true;
      this.$axios
        .post(global_.baseUrl + '/admin/switch', { user_account: userAccount })
        .then(res => {
          this.loading = false;
          if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
          else if (res.data.ret_code === 0) {
            this.$message({ message: res.data.extra || '切换成功', type: 'success' });
            localStorage.setItem('ms_username', userAccount);
            localStorage.setItem('userType', '1');
            window.location.reload();
          } else this.handleApiError(res.data.extra || '切换失败');
        })
        .catch(err => {
          this.loading = false;
          this.handleApiError('切换渠道请求失败: ' + err.message);
        });
    },
    openChangePasswordDialogForUser: function (account) {
      this.dialogs.changePassword.currentAccount = account;
      this.dialogs.changePassword.visible = true;
    },
    adminResetPassword: function (account) {
      this.loading = true;
      this.$axios
        .post(global_.baseUrl + '/admin/reset', { user_account: account })
        .then(res => {
          this.loading = false;
          if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
          else if (res.data.ret_code === 0) this.$message({ message: res.data.extra || '密码重置成功', type: 'success' });
          else this.handleApiError(res.data.extra || '密码重置失败');
        })
        .catch(err => {
          this.loading = false;
          this.handleApiError('密码重置请求失败: ' + err.message);
        });
    },
    handleSavePasswordChange: function (formData) {
      this.fullscreenLoading = true;
      this.$axios
        .post(global_.baseUrl + '/admin/change', formData)
        .then(res => {
          this.fullscreenLoading = false;
          const dialogRef = this.$refs.changePasswordDialogRef;
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
            if (dialogRef) dialogRef.onSaveError();
          } else if (res.data.ret_code === 0) {
            this.$message({ message: res.data.extra || '密码修改成功', type: 'success' });
            if (dialogRef) dialogRef.onSaveSuccess();
          } else {
            this.handleApiError(res.data.extra || '密码修改失败');
            if (dialogRef) dialogRef.onSaveError();
          }
        })
        .catch(err => {
          this.fullscreenLoading = false;
          this.handleApiError('密码修改请求失败: ' + err.message);
          if (this.$refs.changePasswordDialogRef) this.$refs.changePasswordDialogRef.onSaveError();
        });
    },
    addNewGatewayRow: function () {
      // 检查是否已有正在编辑的行
      const editingRow = this.gatewayData.find(item => item.isEditing || item.isNew);
      if (editingRow) {
        this.$message.warning('请先完成当前行的操作');
        return;
      }

      // 添加新行
      const newRow = {
        gwChannel: localStorage.getItem('ms_username'),
        deviceID: '',
        gwID: '',
        onceAuth: false,
        nextAuthTime: '',
        isNew: true,
        isEditing: true
      };
      this.gatewayData.push(newRow);
    },
    toggleEditGateway: function (row) {
      // 检查是否已有正在编辑的行
      const editingRow = this.gatewayData.find(item => item.isEditing && item !== row);
      if (editingRow) {
        this.$message.warning('请先完成当前行的操作');
        return;
      }

      row.isEditing = !row.isEditing;
      this.$forceUpdate(); // 确保视图更新
    },
    cancelEditGateway: function (row) {
      if (row.isNew) {
        // 如果是新增的行，直接删除
        const index = this.gatewayData.indexOf(row);
        if (index !== -1) {
          this.gatewayData.splice(index, 1);
        }
      } else {
        // 如果是编辑已有的行，取消编辑状态
        row.isEditing = false;
      }
    },
    saveGateway: function (row) {
      // 验证必填字段
      if (!row.deviceID || !row.gwID) {
        this.$message.warning('设备ID和网关ID不能为空');
        return;
      }

      // 准备保存数据
      const params = {
        user_account: localStorage.getItem('ms_username'),
        gw_channel: row.gwChannel,
        device_id: row.deviceID,
        gw_id: row.gwID,
        once_auth: row.onceAuth,
        next_auth_time: row.nextAuthTime
      };

      this.loading2 = true;
      this.$axios
        .post(global_.baseUrl + '/device/updateGateway', params)
        .then(res => {
          this.loading2 = false;
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
          } else if (res.data.ret_code === 0) {
            this.$message({ message: row.isNew ? '添加成功' : '更新成功', type: 'success' });
            // 重置行状态
            row.isEditing = false;
            row.isNew = false;
            // 刷新数据
            this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
          } else {
            this.handleApiError(res.data.extra || '操作失败');
          }
        })
        .catch(err => {
          this.loading2 = false;
          this.handleApiError('网关操作请求失败: ' + err.message);
        });
    },
    updateGatewayAuthStatus: function (gatewayRow) {
      const params = {
        device_id: gatewayRow.deviceID,
        gw_id: gatewayRow.gwID,
        once_auth: gatewayRow.onceAuth,
        next_auth_time: gatewayRow.nextAuthTime,
        user_account: localStorage.getItem('ms_username'),
        gw_channel: localStorage.getItem('ms_username')
      };
      this.loading2 = true;
      this.$axios
        .post(global_.baseUrl + '/device/updateGateway', params)
        .then(res => {
          this.loading2 = false;
          if (res.data.ret_code === '1001') {
            this.handleApiError(res.data.extra, true);
          } else if (res.data.ret_code === 0) {
            this.$message({ message: '认证状态更新成功', type: 'success' });
          } else {
            this.handleApiError(res.data.extra || '更新失败');
          }
        })
        .catch(err => {
          this.loading2 = false;
          this.handleApiError('认证状态更新请求失败: ' + err.message);
        });
    },
    deleteGateway: function (device_id, gw_id) {
      this.$confirm('此操作将删除该网关, 是否继续?', '提示', { type: 'warning' }).then(() => {
        const params = { device_id: device_id, gw_id: gw_id, user_account: localStorage.getItem('ms_username'), gw_channel: localStorage.getItem('ms_username') };
        this.$axios
          .post(global_.baseUrl + '/device/deleteGateway', params)
          .then(res => {
            if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
            else if (res.data.ret_code === 0) {
              this.$message({ message: '删除成功', type: 'success' });
              this.fetchGatewayDataForChannel(localStorage.getItem('ms_username'));
            } else this.handleApiError(res.data.extra || '删除失败');
          })
          .catch(err => this.handleApiError('删除网关请求失败: ' + err.message));
      });
    },
    openImportRouterDialogForUser: function (account) {
      this.dialogs.importRouter.currentAccount = account;
      this.dialogs.importRouter.visible = true;
    },
    handleImportRouterUploadSuccess: function (response) {
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
    handleImportRouterUploadError: function (err) {
      this.handleApiError('文件上传失败: ' + (err.message || '未知错误'));
      if (this.$refs.importRouterDialogRef) this.$refs.importRouterDialogRef.onUploadFinished(false);
    },
    deleteChannel(account) {
      this.$confirm('此操作将删除该渠道, 是否继续?', '提示', { type: 'warning' }).then(() => {
        this.loading = true;
        this.$axios
          .post(global_.baseUrl + '/admin/deleteChannel', { userAccount: account })
          .then(res => {
            this.loading = false;
            if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
            else if (res.data.ret_code === 0) {
              this.$message({ message: '删除成功', type: 'success' });
              this.handleUserStatusFilterChange();
            } else this.handleApiError(res.data.extra || '删除失败');
          })
          .catch(err => {
            this.loading = false;
            this.handleApiError('删除渠道请求失败: ' + err.message);
          });
      });
    },
    handleImportRouterManualSave: function (formData) {
      this.loading2 = true;
      const dialogRef = this.$refs.importRouterDialogRef;
      this.$axios
        .post(global_.baseUrl + '/device/import', formData)
        .then(res => {
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
        })
        .catch(err => {
          this.loading2 = false;
          this.handleApiError('手动导入路由请求失败: ' + err.message);
          if (dialogRef) dialogRef.onSaveManualError();
        });
    },
    openDeleteRouterDialogForUser: function (account) {
      this.dialogs.deleteRouter.currentAccount = account;
      this.dialogs.deleteRouter.visible = true;
    },
    handleDeleteRouterSave: function (formData) {
      this.$message.warning('删除路由功能API端点未确定，请联系后端开发。');
      console.warn('Attempted to delete router with data:', formData, 'but API endpoint is not specified or incorrect.');
      if (this.$refs.deleteRouterDialogRef) {
        this.$refs.deleteRouterDialogRef.onSaveError();
      }
    },
    exportRouters: function (account) {
      this.performExport(account, '/device/export', '路由器');
    },
    exportClients: function (account) {
      this.performExport(account, '/client/export', '客户端');
    },
    performExport: function (account, urlPath, exportType) {
      this.loading = true;
      this.$axios
        .post(global_.baseUrl + urlPath, { user_account: account })
        .then(res => {
          this.loading = false;
          if (res.data.ret_code === '1001') this.handleApiError(res.data.extra, true);
          else if (res.data.ret_code === 0) {
            const filePath = res.data.extra;
            const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
            const link = document.createElement('a');
            link.href = global_.baseUrl + filePath;
            link.download = fileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            this.$message({ message: `${exportType}导出成功`, type: 'success' });
          } else this.handleApiError(res.data.extra || `${exportType}导出失败`);
        })
        .catch(err => {
          this.loading = false;
          this.handleApiError(`${exportType}导出请求失败: ` + err.message);
        });
    },
    handleTablePageChange: function (newPage) {
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
    filterUserStatusTag: function (value, row) {
      return row.userStatus == value;
    }
  }
};
</script>

<style scoped>
  /* 配置 Tailwind 颜色和字体 */
  @layer utilities {
    .content-auto {
      content-visibility: auto;
    }
    .bg-primary {
      background-color: #409eff;
    }
    .text-primary {
      color: #409eff;
    }
    .hover\:bg-primary\/90:hover {
      background-color: rgba(64, 158, 255, 0.9);
    }
  }
</style>  