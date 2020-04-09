<template>
  <div>
    <li>新一次</li>
    <router-link :to="{name:'new'}">去新的</router-link>
    <router-link to="main">返回</router-link>
    <router-view />
  </div>
</template>
<script>
export default {}
</script>
<style lang="scss" scoped></style>
