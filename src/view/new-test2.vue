<template>
  <div>
    <input type="text" @input="print">
    <div>
      {{ value }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'Value',
  data() {
    return {
      value: '',
      n: null
    }
  },
  methods: {
    print(val) {
      if (this.n) {
        clearTimeout(this.n)
      }
      this.n = setTimeout(() => {
        this.value = val.srcElement.value
        this.n = null
      }, 1500)
    }
  }
}
</script>
