<template>
    <div class="wrapper">
        <v-head></v-head>
        <v-sidebar></v-sidebar>
        <div class="content">
            <div class="main-cont"><transition name="move" mode="out-in"><router-view></router-view></transition></div>
            <v-footer></v-footer>
        </div>
    </div>
</template>

<script>
    import vHead from './Header.vue';
    import vSidebar from './Sidebar.vue';
    import vFooter from './Footer.vue';
    export default {
        components:{
            vHead, vSidebar,vFooter
        }
    }
</script>
<style>
    .main-cont{
        min-height:500px;
    }
</style>
