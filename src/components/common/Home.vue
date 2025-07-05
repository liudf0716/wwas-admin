<template>
  <div class="wrap">
    <v-head></v-head>

    <div class="sidebar sidebar2">
      <el-menu :default-active="onRoutes" :default-openeds="defaultOpeneds" class="el-menu-vertical" router :collapse-transition="isTransition" :collapse="isCollapse">
        <template v-for="item in currentMenuItems">
          <el-submenu v-if="item.subs && item.subs.length > 0" :index="item.index">
            <template #title>
              <i :class="item.icon"></i>
              <span>{{ item.title }}</span>
            </template>
            <el-menu-item v-for="subItem in item.subs" :key="subItem.index" :index="subItem.index" style="margin-left: 4px">
              {{ subItem.title }}
            </el-menu-item>
          </el-submenu>

          <el-menu-item v-else :index="item.index">
            <i :class="item.icon"></i>
            <span>{{ item.title }}</span>
          </el-menu-item>
        </template>

        <div class="coll-cont" :class="{ iscoll: isCollapse, nocoll: !isCollapse }" @click="toggleCollapse">
          <i class="el-icon-my-arrow" :class="{ 'el-icon-d-arrow-right': isCollapse, 'el-icon-d-arrow-left': !isCollapse }"></i>
        </div>
      </el-menu>

      <div class="content">
        <div class="main-cont">
          <transition name="move" mode="out-in">
            <router-view></router-view>
          </transition>
        </div>
        <v-footer></v-footer>
      </div>
    </div>
  </div>
</template>

<script>
import vHead from './Header.vue';
import vFooter from './Footer.vue';

export default {
  data() {
    return {
      isCollapse: false,
      isTransition: false,
      userType: localStorage.getItem('userType') || '1',
      menuConfig: {
        superAdmin: {
          items: [
            {
              icon: 'el-icon-menu',
              index: '2',
              title: '渠道管理',
              subs: [{ index: 'basetable', title: '渠道列表' }]
            },
            {
              icon: 'el-icon-bank-card',
              index: '4',
              title: '设备管理',
              subs: [
                { index: 'devstatus', title: '设备状态' },
                { index: 'cltstatus', title: '认证用户' }
              ]
            },
            {
              icon: 'el-icon-mobile-phone',
              index: '5',
              title: '认证管理',
              subs: [{ index: 'approve', title: '认证设置' }]
            },
            {
              icon: 'el-icon-document',
              index: '6',
              title: '日志管理',
              subs: [
                { index: 'operation', title: '操作日志' },
                { index: 'authlog', title: '认证日志' },
                { index: 'eventlog', title: '上网日志' }
              ]
            },
            {
              icon: 'el-icon-setting',
              index: '7',
              title: '系统设置',
              subs: [{ index: 'sysinfo', title: '系统信息' }]
            }
          ],
          defaultOpeneds: ['2', '4', '5', '6', '7']
        },
        normalUser: {
          items: [
            {
              icon: 'el-icon-menu',
              index: '3',
              title: '渠道设备',
              subs: [{ index: 'basetable', title: '认证设备' }]
            },
            {
              icon: 'el-icon-bank-card',
              index: '4',
              title: '设备管理',
              subs: [
                { index: 'devstatus', title: '设备状态' },
                { index: 'cltstatus', title: '认证用户' },
                { index: 'fwUpgrade', title: '固件升级' }
              ]
            },
            {
              icon: 'el-icon-mobile-phone',
              index: '5',
              title: '认证管理',
              subs: [{ index: 'approve', title: '认证设置' }]
            },
            {
              icon: 'el-icon-help',
              index: '6',
              title: '固件管理',
              subs: [{ index: 'firmware', title: '固件列表' }]
            }
          ],
          defaultOpeneds: ['3', '4', '5', '6']
        }
      }
    };
  },
  computed: {
    onRoutes() {
      return this.$route.path.replace('/', '');
    },
    currentMenuItems() {
      return this.userType === '1' ? this.menuConfig.normalUser.items : this.menuConfig.superAdmin.items;
    },
    defaultOpeneds() {
      return this.userType === '1' ? this.menuConfig.normalUser.defaultOpeneds : this.menuConfig.superAdmin.defaultOpeneds;
    }
  },
  methods: {
    toggleCollapse() {
      this.isCollapse = !this.isCollapse;
    }
  },
  components: {
    vHead,
    vFooter
  },
  created() {
    // 监听路由变化，确保菜单选中状态正确
    this.$watch(
      () => this.$route.path,
      () => {
        // 可以添加路由变化时的菜单处理逻辑
      }
    );
  }
};
</script>

<style scoped>
  @import '../../assets/css/theme.css';

  /* 侧边栏折叠控制样式优化 */
  .coll-cont {
    display: flex;
    justify-content: center;
    padding: 10px 0;
    cursor: pointer;
  }

  .iscoll {
    margin-left: -5px;
  }

  .nocoll {
    margin-left: 0;
  }
</style>