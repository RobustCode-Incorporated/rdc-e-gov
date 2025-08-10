import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
  }),
  getters: {
    payload: (state) => {
      if (!state.token) return null;
      try {
        const payloadBase64 = state.token.split('.')[1];
        return JSON.parse(atob(payloadBase64));
      } catch {
        return null;
      }
    }
  },
  actions: {
    setToken(token) {
      this.token = token;
      localStorage.setItem('token', token);
    },
    logout() {
      this.token = null;
      localStorage.removeItem('token');
    }
  }
});