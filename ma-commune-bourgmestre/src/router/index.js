import { createRouter, createWebHistory } from 'vue-router';
import DashboardBourgmestre from '../views/DashboardBourgmestre.vue';
import Demandes from '../views/Demandes.vue';
import Agents from '../views/Agents.vue';

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/dashboard', component: DashboardBourgmestre },
  { path: '/demandes', component: Demandes },
  { path: '/agents', component: Agents },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;