import { createRouter, createWebHistory } from 'vue-router';
import LoginAgent from '../views/LoginAgent.vue';
import DashboardAgent from '../views/DashboardAgent.vue';
import DemandesAgent from '../views/DemandesAgent.vue';
import DemandeDetailAgent from '../views/DemandeDetailsAgent.vue';

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'LoginAgent', component: LoginAgent },
  { path: '/dashboard', name: 'DashboardAgent', component: DashboardAgent },
  { path: '/demandes', name: 'DemandesAgent', component: DemandesAgent },
  { path: '/demandes/:id', name: 'DemandeDetailsAgent', component: DemandeDetailAgent },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;