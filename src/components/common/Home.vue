<template>
    <div class="wrap">
        <v-head></v-head>
        <div class="coll-cont" :class="[isCollapse?'iscoll':'nocoll']" @click="clickCollapse">
            <i class="el-icon-my-arrow" :class="[isCollapse?'el-icon-d-arrow-right':'el-icon-d-arrow-left']"></i>
        </div>
        <div class="sidebar sidebar2">
            <el-menu :default-active="onRoutes" class="el-menu-vertical-demo" theme="dark" unique-opened router :collapse-transition="isTransition" @open="handleOpen" @close="handleClose" :collapse="isCollapse">
                <template v-for="item in isUser === '1' ? userItems : superItems">
                    <template v-if="item.subs">
                        <el-submenu :index="item.index">
                            <template slot="title"><i :class="item.icon"></i><span slot="title">{{ item.title }}</span></template>
                            <el-menu-item v-for="(subItem,i) in item.subs" :key="i" :index="subItem.index">{{subItem.title }}</el-menu-item>
                        </el-submenu>
                    </template>
                    <template v-else>
                        <el-menu-item :index="item.index"><i :class="item.icon"></i><span slot="title">{{ item.title }}</span></el-menu-item>
                    </template>
                </template>
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
    // import vSidebar from './Sidebar.vue';
    import vFooter from './Footer.vue';

    export default {
        data() {
            return {
                isCollapse: false,
                collapseIcon:'el-icon-d-arrow-left',
                isTransition:false,
                isUser:localStorage.getItem('userType'),
                superItems: [
                {
                        icon: 'el-icon-menu',
                        index: '2',
                        title: '渠道管理',
                        subs: [
                            {
                                index: 'basetable',
                                title: '渠道列表'
                            },
                        ]
                    },
                    {
                        icon: 'el-icon-setting',
                        index: '4',
                        title: '设备管理',
                        subs: [
                            {
                                index: 'devstatus',
                                title: '设备状态'
                            },
                            {
                                index: 'cltstatus',
                                title: '认证用户'
                            }
                        ]
                    },
                    {
                        icon: 'el-icon-document',
                        index: '5',
                        title: '认证管理',
                        subs: [
                            {
                                index: 'approve',
                                title: '认证设置'
                            }
                        ]
                    }
                ],
                userItems: [
                    {
                        icon: 'el-icon-menu',
                        index: '3',
                        title: '渠道设备',
                        subs: [
                            {
                                index: 'basetable',
                                title: '认证设备'
                            }
                        ] 
                    },  
                    {
                        icon: 'el-icon-setting',
                        index: '4',
                        title: '设备管理',
                        subs: [
                            {
                                index: 'devstatus',
                                title: '设备状态'
                            },
                            {
                                index: 'cltstatus',
                                title: '认证用户'
                            }
                        ]
                    },
                    {
                        icon: 'el-icon-document',
                        index: '5',
                        title: '认证管理',
                        subs: [
                            {
                                index: 'approve',
                                title: '认证设置'
                            }
                        ]
                    }
                ]
            };
        },
        computed:{
            onRoutes(){
                return this.$route.path.replace('/','');
            }
        },
        methods: {
            handleOpen(key, keyPath) {
                console.log(key, keyPath);
            },
            handleClose(key, keyPath) {
                console.log(key, keyPath);
            },
            clickCollapse(){
                this.isCollapse = !this.isCollapse;

            }
        },
        components: {
            vHead, vFooter
        }
    }
</script>
<style scoped>
    @import '../../assets/css/theme.css';
</style>
