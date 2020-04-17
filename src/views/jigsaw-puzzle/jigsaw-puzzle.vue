<template>
  <div class="a-block">
    <div v-if="is">
      <router-link :to="{name:'jigsaw-puzzle-one'}">拼图（一）</router-link>
    </div>
    <router-view />
  </div>
</template>
<script>
export default {
  computed: {
    is() {
      return this.$route.name === 'jigsaw-puzzle'
    }
  }
}
</script>
