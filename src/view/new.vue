<template>
  <div>
    <span>父组件</span>
    <div>
      a：
      <input v-model.number="obj.a" type="text">
    </div>
    <div>
      b：
      <input v-model.number="obj.b" type="text">
    </div>
    <new-test :obj="obj">
      <template v-slot:a1="slotProps">
        {{ 888+slotProps.a1 }}
      </template>
      <template #a2>
        25
      </template>
    </new-test>
    <Render :meta="obj.a" />
  </div>
</template>
<script>
import NewTest from './new-test'
import Render from './render'
export default {
  components: { NewTest, Render },
  data() {
    return {
      hasmap: 0,
      obj: {
        a: 1,
        b: 2
      }
    }
  },
  beforeCreate() {
    // console.log(this._vnode)
  },
  beforeMount() {
    // console.log(this)
  },
  mounted() {
    // console.log(this.$el, this.$template)
    console.log(this._vnode)
  },
  methods: {
    bianli(obj) {

    }
  }
}
</script>
