<template>
  <div>
    <h2 v-once v-colRed>3*3拼图</h2>
    <div class="out-box">
      <div ref="box" class="box">
        <div
          v-for="(item, index) in jigsawArr"
          :id="'id' + index"
          :key="index"
          class="small-box"
          :class="{ 'm-r-t-2': (index + 1) % 3 !== 0 }"
          @click="active(index)"
        >
          {{ item }}
        </div>
      </div>
    </div>
    <div>
      <h3>步数：{{ number }}</h3>
      <h3>时间：{{ time }}</h3>
      <button v-focus @click="againArr">开始</button>
    </div>
    <router-link :to="{name:'nextTick'}">去哪里</router-link>
    <router-link to="new">Home</router-link>
    <div v-if="win" class="modal" />
    <router-view />
  </div>
</template>
<script>
export default {
  directives: {
    focus: {
      // 指令的定义
      inserted(el) {
        el.focus()
      }
    },
    colRed: {
      inserted(el) {
        console.log(el)
      }
    }
  },
  data() {
    return {
      jigsawArr: [],
      number: 0,
      spaceIndex: 8,
      time: '00:00',
      n: null,
      win: false
    }
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
      this.win = false
      this.jigsawFn()
    },
    // 创建一个长度为n的数组并且随机打乱
    arrLength(num) {
      return Array.from({ length: num }, (item, index) => index + 1).sort(() =>
        Math.random() > 0.5 ? 1 : -1
      )
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
      return a % 2 !== 0
    },
    // 添加最后一行空
    arrEmpty(arr) {
      arr.push('')
      return arr
    },
    // 赋值
    jigsawFn() {
      let arr
      let bol = true
      while (bol) {
        arr = this.arrLength(8)
        bol = this.isUnsolvable(arr)
      }
      this.jigsawArr = this.arrEmpty(arr)
    },
    // 开始游戏/重新开始
    againArr() {
      if (this.jigsawArr.length === 0) {
        this.jigsawFn()
      } else {
        this.initialize()
      }
      this.Timing()
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
          if (
            spaceIndex === 1 ||
            spaceIndex === 3 ||
            spaceIndex === 5 ||
            spaceIndex === 7
          ) {
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
    // 判断是否成功
    success(arr) {
      return arr.every((item, index) => {
        if (item !== '') {
          return item - 1 === index
        }
        return true
      })
    },
    // 点击
    active(ind) {
      if (ind !== this.spaceIndex && this.spaceAbout(ind)) {
        this.jigsawArr.splice(this.spaceIndex, 1, this.jigsawArr[ind])
        this.jigsawArr.splice(ind, 1, '')
        this.$nextTick(() => {
          if (this.success(this.jigsawArr)) {
            this.number++
            console.log(document.querySelector('#id8').innerHTML)
            alert(1)
            return
            // this.win = true
            // clearInterval(this.n)
            // this.againArr()
          } else {
            this.spaceIndex = ind
            this.number++
          }
        })
      }
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
  background: #eee;
  width: 300px;
  height: 300px;
  display: flex;
  flex-wrap: wrap;
  font-size: 52px;
  box-sizing: border-box;
}
.small-box {
  box-sizing: border-box;
  border: 2px solid #eee;
  width: 33%;
  height: 33%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}
.modal {
  height: 100%;
  width: 100%;
  opacity: 0.7;
  background-color: #000;
  position: fixed;
  top: 0;
}
</style>
