<template>
    <div class="container">
      <header class="page-header">
        <h1>Gestion des Administrateurs</h1>
      </header>
  
      <section v-if="loading">Chargement des administrateurs...</section>
  
      <section v-else class="grid">
        <div v-for="admin in administrateurs" :key="admin.id" class="card">
          <h2>{{ admin.nomComplet }}</h2>
          <p><strong>Username :</strong> {{ admin.username }}</p>
          <p><strong>Email :</strong> {{ admin.email || 'N/A' }}</p>
          <p><strong>Commune ID :</strong> {{ admin.communeId }}</p>
          <p><strong>Rôle :</strong> {{ admin.role }}</p>
        </div>
      </section>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'Administrateurs',
    data() {
      return {
        administrateurs: [],
        loading: true,
      };
    },
    async mounted() {
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get('http://localhost:4000/api/administrateurs', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.administrateurs = res.data;
      } catch (error) {
        console.error('Erreur lors du chargement des administrateurs :', error);
      } finally {
        this.loading = false;
      }
    },
  };
  </script>
  
  <style scoped>
  .container {
    padding: 32px;
    background: #f7f7f7;
    font-family: 'Roboto', sans-serif;
  }
  .page-header {
    margin-bottom: 24px;
  }
  .grid {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
  }
  .card {
    background: white;
    border-radius: 6px;
    padding: 20px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.1);
    width: 300px;
  }
  .card h2 {
    margin-bottom: 8px;
    color: #003DA5;
  }
  </style>