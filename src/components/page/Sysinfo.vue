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
        <el-form-item label="系统名称" prop="systemName">
          <el-input v-model="systemInfo.systemName" placeholder="请输入系统名称"></el-input>
        </el-form-item>

        <el-form-item label="Logo地址" prop="logo">
          <el-input v-model="systemInfo.logo" placeholder="请输入Logo地址"></el-input>
        </el-form-item>

        <el-form-item label="公司名称" prop="company">
          <el-input v-model="systemInfo.company" placeholder="请输入公司名称"></el-input>
        </el-form-item>

        <el-form-item label="ICP备案号" prop="icpRecord">
          <el-input v-model="systemInfo.icpRecord" placeholder="请输入ICP备案号"></el-input>
        </el-form-item>

        <el-form-item label="版权信息" prop="copyright">
          <el-input v-model="systemInfo.copyright" placeholder="请输入版权信息"></el-input>
        </el-form-item>

        <el-form-item label="联系邮箱" prop="contactEmail">
          <el-input v-model="systemInfo.contactEmail" placeholder="请输入联系邮箱"></el-input>
        </el-form-item>

        <el-form-item label="系统版本" prop="systemVersion">
          <el-input v-model="systemInfo.systemVersion" placeholder="请输入系统版本"></el-input>
        </el-form-item>

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
        contactEmail: '',
        systemVersion: ''
      },
      defaultSystemInfo: {}
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
            // 保存默认值用于重置
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
    }
  }
};
</script>

<style scoped>
  .system-settings-container {
    /* padding: 20px; */
    background-color: #f5f7fa;
    /* min-height: 100vh; */
  }

  .box-card {
    margin-bottom: 20px;
  }
</style>  