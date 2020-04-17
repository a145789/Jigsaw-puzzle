<template>
  <div class="a-block">
    <div v-if="is">
      <router-link :to="{name:'children-parent-params'}">1.父子组件传参</router-link>
      <router-link :to="{name:'drag-and-drop'}">2.实现拖拽</router-link>
    </div>
    <router-view />
  </div>
</template>
<script>
export default {
  computed: {
    is() {
      return this.$route.name === 'test-main'
    }
  }
}
</script>
