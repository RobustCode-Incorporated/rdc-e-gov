import { createRouter, createWebHistory } from 'vue-router';
import LoginBourgmestre from '../views/LoginBourgmestre.vue';
import DashboardBourgmestre from '../views/DashboardBourgmestre.vue';
import Demandes from '../views/Demandes.vue';
import Agents from '../views/Agents.vue';

const routes = [
  { path: '/', name: 'LoginBourgmestre', component: LoginBourgmestre },
  { path: '/dashboard-bourgmestre', name: 'DashboardBourgmestre', component: DashboardBourgmestre },
  { path: '/demandes',name: 'Demandes',component: Demandes},
  { path: '/agents',name: 'Agents',component: Agents},
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;