import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)
const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      redirect: '/main'
    },
    {
      path: '/main',
      name: 'main',
      component: () => import('../view/main.vue'),
      meta: { title: '主要' }
    },
    {
      path: '/haxi',
      name: 'haxi',
      component: () => import('../view/new.vue')
    }
  ]
})
export default router
