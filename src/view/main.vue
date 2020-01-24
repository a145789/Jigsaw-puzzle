<template>
  <div>
    <h2>3*3拼图</h2>
    <div class="out-box">
      <div class="box">
        <div
          v-for="(item,index) in arrTable"
          :key="index"
          class="small-box"
          :class="{'m-r-t-2':(index  + 1) % 3 !==0 }"
          @click="active(index)"
        >{{item.value}}</div>
      </div>
      <h3>步数：{{number}}</h3>
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      jigsawArr: [],
      number: 0
    }
  },
  created() {
    this.againArr()
  },
  methods: {
    //创建一个长度为n的数组
    arrLength(num) {
      let arr = new Array(num)
      return arr.reduce((pre, cur, index) => {
        return pre.push(index)
      }, [])
    },
    //初始化
    initialize() {
      this.jigsawArr = []
      this.number = 0
      this.arrLength(9)
    },
    //
    // 加载以及重新加载
    againArr() {
      this.initialize()
    },
    // 随机打乱数组
    randomArr(arr) {
      return Math.floor(Math.random() * len)
    },
    // 判断是否成功
    success(arr) {
      return arr.every(item => item === item)
    },
    active(ind) {
      if (this.success(this.arrTable)) {
        alert('成功！！！')
        this.againArr()
      }
    }
  },
}
</script>
<style lang="scss" scoped>
.out-box {
  display: flex;
  justify-content: center;
}
.box {
  padding: 1px;
  height: 600px;
  width: 600px;
  background: #eee;
  display: flex;
  flex-wrap: wrap;
  font-size: 52px;
  box-sizing: border-box;
}
.small-box {
  width: 33%;
  height: 33%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}
.m-r-t-2 {
  margin: 0 2px 2px 0;
}
</style>