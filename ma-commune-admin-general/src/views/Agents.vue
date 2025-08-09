<template>
    <div class="container">
      <header class="page-header">
        <h1>Gestion des Agents</h1>
      </header>
  
      <section v-if="loading">Chargement des agents...</section>
  
      <section v-else class="grid">
        <div v-for="agent in agents" :key="agent.id" class="card">
          <h2>{{ agent.nomComplet }}</h2>
          <p><strong>Username :</strong> {{ agent.username }}</p>
          <p><strong>Email :</strong> {{ agent.email || 'N/A' }}</p>
          <p><strong>Commune ID :</strong> {{ agent.communeId }}</p>
        </div>
      </section>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'Agents',
    data() {
      return {
        agents: [],
        loading: true,
      };
    },
    async mounted() {
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get('http://localhost:4000/api/agents', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.agents = res.data;
      } catch (error) {
        console.error('Erreur chargement agents :', error);
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