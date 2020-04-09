<template>
  <div>
    <div style="margin-top:40px">子组件</div>
    <!-- <img src="../assets/img/ylsc.ab940c02.png" /> -->
    {{ a + b }}
    {{ typeof obj.a }} {{ typeof obj.b }}
    <slot name="a1" :a1="a" />
    <slot name="a2" />
  </div>
</template>
<script>
export default {
  name: 'Wather',
  props: {
    obj: {
      type: Object,
      default: () => ({})
    }
  },
  data() {
    return {
      hasmap: 8
    }
  },
  computed: {
    a() {
      return Number(this.obj.a)
    },
    b() {
      return Number(this.obj.b)
    }
  }
}
</script>
