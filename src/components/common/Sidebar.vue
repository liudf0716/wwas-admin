<template>
    <div class="sidebar">
        <el-menu :default-active="onRoutes" class="el-menu-vertical-demo" theme="dark" unique-opened router>
            <template v-for="item in items">
                <template v-if="item.subs">
                    <el-submenu :index="item.index">
                        <template slot="title"><i :class="item.icon"></i>{{ item.title }}</template>
                        <el-menu-item v-for="(subItem,i) in item.subs" :key="i" :index="subItem.index">{{ subItem.title }}
                        </el-menu-item>
                    </el-submenu>
                </template>
                <template v-else>
                    <el-menu-item :index="item.index">
                        <i :class="item.icon"></i>{{ item.title }}
                    </el-menu-item>
                </template>
            </template>
        </el-menu>
    </div>
</template>

<script>
    import global_ from 'components/common/Global';
    export default {
        data() {
            return {
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
                    }
                ]
            }
        },
        computed:{
            onRoutes(){
                return this.$route.path.replace('/','');
            }
        },
        watch:{
            items: function(newItems){
                // this.getUser();
            }
        },
        methods:{
            getUser: function(){
                var self = this;
                self.$axios.post(global_.baseUrl+'/admin/info').then(function(res){
                    if(res.data.ret_code == 0){
                        self.curUser = res.data.ret_msg;
                        self.items = [
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
                                }
                            ]
                    }
                })
            },
        },
        mounted: function(){
            this.getUser();
        },
    }
</script>

<style scoped>
    .sidebar{
        display: block;
        position: absolute;
        width: 250px;
        left: 0;
        top: 70px;
        bottom:0;
        background: #2E363F;
    }
    .sidebar > ul {
        height:100%;
    }
</style>
