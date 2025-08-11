import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    // Empêche l'affichage du logo Vite dans le coin
    hmr: {
      overlay: false,
    },
  },
  // Ou ajoute cette option pour cacher le logo (si supportée)
  clearScreen: false,
})