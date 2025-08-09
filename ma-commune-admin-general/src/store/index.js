import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: null,
  }),
  actions: {
    async login(username, password) {
      try {
        const response = await axios.post('/api/administrateurs-generaux/login-admin-general', { username, password })
        this.token = response.data.token;
        localStorage.setItem('token', this.token);
        // Optionnel : décoder token pour récupérer infos utilisateur
      } catch (error) {
        throw error;
      }
    },
    logout() {
      this.token = null;
      this.user = null;
      localStorage.removeItem('token');
    },
  },
});