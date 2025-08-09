import { createRouter, createWebHistory } from 'vue-router';

// Pages publiques
import LoginAdminGeneral from '../views/LoginAdminGeneral.vue';
const RegisterAdminGeneral = () => import('../views/RegisterAdminGeneral.vue');

// Pages protégées (dashboard + modules)
const Dashboard = () => import('../views/DashboardAdmin.vue');
const Communes = () => import('../views/Communes.vue');
const Administrateurs = () => import('../views/Administrateurs.vue');
const Agents = () => import('../views/Agents.vue');

const routes = [
  {
    path: '/',
    name: 'LoginAdminGeneral',
    component: LoginAdminGeneral
  },
  {
    path: '/register',
    name: 'RegisterAdminGeneral',
    component: RegisterAdminGeneral
  },
  {
    path: '/admin-general/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/communes',
    name: 'Communes',
    component: Communes,
    meta: { requiresAuth: true }
  },
  {
    path: '/administrateurs',
    name: 'Administrateurs',
    component: Administrateurs,
    meta: { requiresAuth: true }
  },
  {
    path: '/agents',
    name: 'Agents',
    component: Agents,
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    redirect: '/admin-general/profile'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Navigation guard : redirige vers login si pas de token
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  if (to.meta.requiresAuth && !token) {
    next({ name: 'LoginAdminGeneral' });
  } else {
    next();
  }
});

export default router;