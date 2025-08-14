import { createRouter, createWebHistory } from 'vue-router';
import LoginBourgmestre from '../views/LoginBourgmestre.vue';
import DashboardBourgmestre from '../views/DashboardBourgmestre.vue';
import Demandes from '../views/Demandes.vue';
import Agents from '../views/Agents.vue';
import DemandeDetailsAdmin from '../views/DemandeDetailsAdmin.vue'; // <-- Importez le nouveau composant

const routes = [
  { 
    path: '/', 
    name: 'LoginBourgmestre', 
    component: LoginBourgmestre 
  },
  { 
    path: '/dashboard-bourgmestre', 
    name: 'DashboardBourgmestre', 
    component: DashboardBourgmestre 
  },
  { 
    path: '/demandes',
    name: 'Demandes',
    component: Demandes
  },
  { 
    path: '/agents',
    name: 'Agents',
    component: Agents
  },
  { 
    path: '/demandes/:id', // <-- Le chemin avec le paramètre dynamique
    name: 'DemandeDetailsAdmin', // <-- Le nom de la route qui sera appelé par le bouton
    component: DemandeDetailsAdmin // <-- Le composant qui affiche les détails d'une seule demande
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;