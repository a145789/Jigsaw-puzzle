<template>
  <div>
    <h2>3*3拼图</h2>
    <div class="out-box">
      <div class="box">
        <div
          v-for="(item,index) in jigsawArr"
          :key="index"
          class="small-box"
          :class="{'m-r-t-2':(index + 1) % 3 !==0 }"
          @click="active(index)"
        >{{ item }}</div>
      </div>
      <div>
        <h3>步数：{{ number }}</h3>
        <h3>时间：{{ time }}</h3>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      jigsawArr: [],
      number: 0,
      spaceIndex: 8,
      time: '00:00',
      n: null
    }
  },
  created() {
    this.againArr()
    this.Timing()
  },
  methods: {
    // 计时器
    Timing() {
      let m = 0
      let s = 1
      this.n = setInterval(() => {
        this.time = (m > 9 ? m : '0' + m) + ':' + (s > 9 ? s : '0' + s)
        s++
        if (s === 59) {
          m++
          s = 0
        }
      }, 1000)
    },
    // 初始化
    initialize() {
      this.number = 0
      this.spaceIndex = 8
      this.time = '00:00'
      this.jigsawFn()
    },
    // 创建一个长度为n的数组
    arrLength(num) {
      return Array.from({ length: num }, (item, index) => index + 1)
    },
    // 随机打乱数组
    randomArr(arr) {
      arr.sort(() => Math.random() > 0.5 ? 1 : -1)
      if (this.isUnsolvable(arr)) {
        return arr
      } else {
        this.randomArr(arr)
      }
    },
    // 判断是否为无解 --- >  如逆序存在奇数则为无解
    isUnsolvable(arr) {
      let a = 0
      arr.forEach((item, index) => {
        for (let i = index + 1, len = arr.length; i < len; i++) {
          if (item > arr[i]) {
            a++
          }
        }
      })
      return !a % 2
    },
    // 添加最后一行空
    arrEmpty(arr) {
      arr.push('')
      return arr
    },
    // 赋值
    jigsawFn() {
      this.jigsawArr = this.arrEmpty(this.randomArr(this.arrLength(8)))
    },
    // 开始游戏/重新开始
    againArr() {
      if (this.jigsawArr.length === 0) {
        this.jigsawFn()
      } else {
        this.initialize()
      }
    },
    // 判断空格是否在元素周边
    spaceAbout(ind) {
      const spaceIndex = this.spaceIndex
      switch (ind) {
        case 0:
          if (spaceIndex === 1 || spaceIndex === 3) {
            return true
          } else {
            return false
          }
        case 1:
          if (spaceIndex === 0 || spaceIndex === 2 || spaceIndex === 4) {
            return true
          } else {
            return false
          }
        case 2:
          if (spaceIndex === 1 || spaceIndex === 5) {
            return true
          } else {
            return false
          }
        case 3:
          if (spaceIndex === 0 || spaceIndex === 4 || spaceIndex === 6) {
            return true
          } else {
            return false
          }
        case 4:
          if (spaceIndex === 1 || spaceIndex === 3 || spaceIndex === 5 || spaceIndex === 7) {
            return true
          } else {
            return false
          }
        case 5:
          if (spaceIndex === 2 || spaceIndex === 4 || spaceIndex === 8) {
            return true
          } else {
            return false
          }
        case 6:
          if (spaceIndex === 3 || spaceIndex === 7) {
            return true
          } else {
            return false
          }
        case 7:
          if (spaceIndex === 6 || spaceIndex === 4 || spaceIndex === 8) {
            return true
          } else {
            return false
          }
        case 8:
          if (spaceIndex === 7 || spaceIndex === 5) {
            return true
          } else {
            return false
          }
        default:
          break
      }
    },
    // 点击
    active(ind) {
      if (ind !== this.spaceIndex && this.spaceAbout(ind)) {
        this.jigsawArr.splice(this.spaceIndex, 1, this.jigsawArr[ind])
        this.jigsawArr.splice(ind, 1, '')
        if (this.success(this.jigsawArr)) {
          alert('成功！！！')
          this.againArr()
          this.n = null
          this.Timing()
        } else {
          this.spaceIndex = ind
          this.number++
        }
      }
    },
    // 判断是否成功
    success(arr) {
      return arr.every((item, index) => {
        if (item !== '') {
          return item - 1 === index
        }
        return true
      })
    }
  }
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
