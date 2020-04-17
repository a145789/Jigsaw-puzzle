export default {
  path: '/test-main',
  name: 'test-main',
  component: () => import('@/views/test-main/test-main'),
  children: [
    {
      path: 'children-parent-params',
      name: 'children-parent-params',
      component: () => import('@/views/test-main/children-parent-params/new')
    },
    {
      path: 'drag-and-drop',
      name: 'drag-and-drop',
      component: () => import('@/views/test-main/drag-and-drop/drag-and-drop')
    }
  ]
}
