<template>
  <div class="system-settings-container">
    <!-- 面包屑导航 -->
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-setting"></i> 系统设置</el-breadcrumb-item>
        <el-breadcrumb-item>系统信息</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <el-card class="box-card" shadow="never">
      <template #header>
        <div class="clearfix">
          <span>系统信息设置</span>
          <el-button style="float: right; padding: 3px 0" type="text" @click="resetSettings"> 重置 </el-button>
        </div>
      </template>
      <el-form :model="systemInfo" ref="systemForm" label-width="120px" size="medium">
        <el-form-item label="Logo" prop="logo">
          <el-upload class="avatar-uploader" :action="uploadUrl" :show-file-list="false" :on-success="handleAvatarSuccess" :before-upload="beforeAvatarUpload">
            <img v-if="logoUrl" :src="logoUrl" class="avatar" />
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
        </el-form-item>

        <el-form-item label="系统名称" prop="systemName">
          <el-input v-model="systemInfo.systemName" placeholder="请输入系统名称"></el-input>
        </el-form-item>

        <!-- <el-form-item label="公司名称" prop="company">
          <el-input v-model="systemInfo.company" placeholder="请输入公司名称"></el-input>
        </el-form-item> -->

        <el-form-item label="版权信息" prop="copyright">
          <el-input v-model="systemInfo.copyright" placeholder="请输入版权信息"></el-input>
        </el-form-item>

        <el-form-item label="ICP备案号" prop="icpRecord">
          <el-input v-model="systemInfo.icpRecord" placeholder="请输入ICP备案号"></el-input>
        </el-form-item>

        <el-form-item label="联系方式" prop="contactInfo">
          <el-input v-model="systemInfo.contactInfo" placeholder="请输入联系方式"></el-input>
        </el-form-item>
        <!-- 
        <el-form-item label="系统版本" prop="systemVersion">
          <el-input v-model="systemInfo.systemVersion" placeholder="请输入系统版本"></el-input>
        </el-form-item> -->

        <el-form-item>
          <el-button type="primary" @click="saveSettings">保存设置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import global_ from 'components/common/Global';

export default {
  data() {
    return {
      systemInfo: {
        systemName: '',
        logo: '',
        company: '',
        icpRecord: '',
        copyright: '',
        contactInfo: '',
        systemVersion: ''
      },
      defaultSystemInfo: {},
      logoUrl: null,
      uploadUrl: global_.baseUrl + '/sysinfo/uploadLogo'
    };
  },
  created() {
    this.fetchSystemInfo();
  },
  methods: {
    fetchSystemInfo() {
      this.$axios
        .get(global_.baseUrl + '/sysinfo/detail')
        .then(res => {
          if (res.data.ret_code === 0) {
            this.systemInfo = res.data.extra;
            this.logoUrl = this.systemInfo.logo; // 保存默认值用于重置
            this.defaultSystemInfo = JSON.parse(JSON.stringify(res.data.extra));
          } else {
            this.$message.error('获取系统信息失败');
          }
        })
        .catch(() => {
          this.$message.error('获取系统信息失败');
        });
    },

    saveSettings() {
      this.$refs.systemForm.validate(valid => {
        if (valid) {
          this.$axios
            .post(global_.baseUrl + '/sysinfo/update', this.systemInfo)
            .then(res => {
              if (res.data.ret_code === 0) {
                this.$message.success('系统信息更新成功');
                // 更新默认值
                this.defaultSystemInfo = JSON.parse(JSON.stringify(this.systemInfo));
                this.$bus.$emit('updateSysinfo', this.systemInfo);
              } else {
                this.$message.error(res.data.extra || '更新失败，请重试');
              }
            })
            .catch(() => {
              this.$message.error('更新失败，请重试');
            });
        } else {
          return false;
        }
      });
    },

    resetSettings() {
      this.systemInfo = JSON.parse(JSON.stringify(this.defaultSystemInfo));
    },
    handleAvatarSuccess(res, file) {
      if (res.ret_code !== 0) {
        this.$message.error('头像上传失败: ' + res.extra);
        return;
      }
      this.$message.success('头像上传成功');
      this.systemInfo.logo = res.extra.url; // 更新系统信息中的logo
      this.logoUrl = res.extra.url; // 更新logoUrl以显示新头像
    },
    beforeAvatarUpload(file) {
      const isLt = file.size / 1024 < 100;
      if (!isLt) {
        this.$message.error('上传头像图片大小不能超过 100k!');
      }
      return isLt;
    }
  }
};
</script>

<style scoped>
  .system-settings-container {
    /* padding: 20px; */
    /* background-color: #f5f7fa; */
    /* min-height: 100vh; */
    /* width: 800px; */
  }

  .box-card {
    margin-bottom: 20px;
  }
  .avatar {
    width: 50px;
    background-color: #262f3e;
  }
</style>  