import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)
const router = new Router({
  mode: 'history',
  base: '',
  routes: [
    {
      path: '/',
      name: '/',
      redirect: '/main'
    },
    {
      path: '/main',
      name: 'main',
      component: () => import('../view/main.vue'),
      meta: { title: '主要' },
      children: [
        {
          path: 'nextTick',
          name: 'nextTick',
          component: () => import('../view/nextTick'),
          children: [
            {
              path: 'new',
              name: 'new',
              component: () => import('../view/new.vue')
            }
          ]
        }
      ]
    },
    {
      path: '/home',
      name: 'home',
      component: () => import('../view/main.vue'),
      alias: '/main/nextTick/new'
    },
    {
      path: '/test',
      name: 'test',
      component: () => import('../view/new-test2')
    }
  ]
})
export default router
