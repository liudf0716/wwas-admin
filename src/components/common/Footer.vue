<template>
    <div class="footer">

        <div class="p">This site is powered by the open source&nbsp;
            <a target="_blank" href="https://github.com/wificoin-project/">WiFicoin Opensource Project</a>&nbsp;
            project created by wificoin team &nbsp;
            <a href="http://www.gnu.org/licenses/gpl-2.0.html">GPL</a>
        </div>
        <div class="p">
            <i class="el-icon-star-on"></i>&nbsp; Support this project by donating&nbsp;<i class="fa fa-btc"></i>&nbsp;<a target="_blank" href="https://wfc.xyblock.net/#/wifiPortal/donate">WFC</a>
        </div>
        <div class="p" id="communityFooter">
            Community&nbsp;<i class="fa fa-comment"></i>&nbsp;: &nbsp;<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5StVwau">QQ群(424031785)</a>
            &nbsp;&nbsp;|&nbsp;&nbsp;
            <iframe src="http://ghbtns.com/github-btn.html?user=liudf0716&amp;repo=node-open-mining-portal&amp;type=watch&amp;count=true" allowtransparency="true" frameborder="0" scrolling="0" width="140" height="20"></iframe>
        </div>

    </div>
</template>
<script>
    import global_ from 'components/common/Global';
    export default {
        data() {
            return {

            }
        },
        computed:{

        },
        methods:{

        }
    }
</script>
<style scoped>
    .footer{
        position: relative;
        box-sizing: border-box;
        width: 100%;
        color: #aaa;
        text-align: center;
        font-size:14px;
        margin-top:30px;
        border-top:1px solid #eee;
        padding-top:30px;
    }
    .footer .p{
        height:30px;
        line-height:30px;
    }
    .footer a{
        font-size:15px;
        color:#4db3ff;
    }

    .diainp{width:217px;}
</style>
