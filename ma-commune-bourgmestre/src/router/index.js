import { createRouter, createWebHistory } from 'vue-router';
import LoginBourgmestre from '../views/LoginBourgmestre.vue';
import DashboardBourgmestre from '../views/DashboardBourgmestre.vue';

const routes = [
  { path: '/', name: 'LoginBourgmestre', component: LoginBourgmestre },
  { path: '/dashboard', name: 'DashboardBourgmestre', component: DashboardBourgmestre },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;