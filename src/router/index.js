import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

import JigsawPuzzle from './modules/Jigsaw-puzzle'
import TestMain from './modules/test-main'
const routes = [
  {
    path: '/',
    redirect: '/main'
  },
  {
    path: '/main',
    name: 'main',
    component: () => import('@/views/main')
  },
  JigsawPuzzle,
  TestMain,
  {
    path: '*',
    name: 'no-page',
    component: () => import('@/views/abnormal/404.vue')
  }
]

const router = new Router({
  mode: 'history',
  routes
})
export default router
