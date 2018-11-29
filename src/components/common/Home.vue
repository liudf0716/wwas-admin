<template>
    <div class="wrapper">
        <v-head></v-head>
        <div class="coll-cont" :class="[isCollapse?'iscoll':'nocoll']" @click="clickCollapse">
            <i class="el-icon-my-arrow" :class="[isCollapse?'el-icon-d-arrow-right':'el-icon-d-arrow-left']"></i>
        </div>
        <div class="sidebar sidebar2">
            <el-menu :default-active="onRoutes" class="el-menu-vertical-demo" theme="dark" unique-opened router :collapse-transition="isTransition" @open="handleOpen" @close="handleClose" :collapse="isCollapse">
                <template v-for="item in items">
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

        <!--<div class="content">-->
        <!--<div class="main-cont"><transition name="move" mode="out-in"><router-view></router-view></transition></div>-->
        <!--<v-footer></v-footer>-->
        <!--</div>-->
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
                items: [
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
<style>
    .main-cont {
        min-height: 500px;
    }
    .el-menu-vertical-demo {
        float: left;
    }
    .el-menu-vertical-demo:not(.el-menu--collapse) {
        width: 250px;
        /*min-height: 400px;*/
    }
    .sidebar2{
        overflow: hidden;
    }
</style>
<style scoped>
    .sidebar{
        width:100%;
        height:100%;
        /*display: block;*/
        position: absolute;
        /*width: 250px;*/
        left: 0;
        top: 110px;
        bottom:0;
        background: #324157;
    }
    .sidebar > ul {
        height:100%;
    }
    .content{
        position: relative;
        top:-110px;
        padding:110px 40px 40px 40px;
        height:100%;
    }
    .coll-cont{
        font-size:14px;
        background-color:#324157;
        display:inline-block;
        height:40px;
        color: #bfcbd9;
        padding:10px 20px;
        box-sizing: border-box;
        cursor: pointer;
        transition: transform .3s;
    }
    .iscoll{
        width:64px;
        /*text-align: center;*/
        transition:width 0.3s ease-in-out;
        /*transition:transform .3s;*/
    }
    .nocoll{
        width:250px;
        text-align: left;
        transition:width 0.3s ease-in-out;
        /*transition:transform .3s*/
    }
    .el-icon-my-arrow{
        padding:0 5px;
    }
</style>
