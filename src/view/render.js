export default {
  props: {
    meta: {
      type: [String, Number],
      default: ''
    }
  },
  render(createElement) {
    return createElement('a', { attrs: {
      href: '#a1'
    }}, '你好' + this.meta)
  }
}
