<template>
  <div class="sidebar"></div>
</template>

<script>
import global_ from 'components/common/Global';
export default {
  data() {
    return {};
  },
  methods: {},
  mounted: function () {
    this.getUser();
  }
};
</script>

<style scoped>
  .sidebar {
    /*display: block;*/
    /*position: absolute;*/
    /*width: 250px;*/
    /*left: 0;*/
    /*top: 70px;*/
    /*bottom:0;*/
    /*background: #2E363F;*/
  }
  .sidebar > ul {
    height: 100%;
  }
</style>
