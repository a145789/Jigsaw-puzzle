export default {
  path: '/jigsaw-puzzle',
  name: 'jigsaw-puzzle',
  component: () => import('@/views/jigsaw-puzzle/jigsaw-puzzle'),
  children: [
    {
      path: 'jigsaw-puzzle-one',
      name: 'jigsaw-puzzle-one',
      component: () => import('@/views/jigsaw-puzzle/jigsaw-puzzle-one')
    }
  ]
}
