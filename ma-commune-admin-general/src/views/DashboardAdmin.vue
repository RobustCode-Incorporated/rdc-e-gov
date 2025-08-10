<template>
  <div class="dashboard-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <h1>Admin Général</h1>
      <nav>
        <router-link to="/communes">📍 Communes</router-link>
        <router-link to="/administrateurs">👥 Bourgmestres</router-link>
        <!-- Ces liens sont cachés pour le moment -->
        <router-link v-if="showAgentsDemandes" to="/agents">🛡️ Agents</router-link>
        <router-link v-if="showAgentsDemandes" to="/demandes">📄 Demandes</router-link>
      </nav>
    </aside>

    <!-- Contenu principal -->
    <main class="content">
      <header class="header-logo">
        <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
      </header>

      <header class="header">
        <h2>Tableau de bord</h2>
      </header>

      <section v-if="loading">Chargement...</section>

      <section v-else class="cards">
        <div class="card">
          <h3>{{ stats.totalCommunes }}</h3>
          <p>Communes totales</p>
        </div>
        <div class="card">
          <h3>{{ stats.communesAvecBourgmestre }}</h3>
          <p>Communes avec bourgmestre</p>
        </div>
        <div class="card">
          <h3>{{ stats.communesSansBourgmestre }}</h3>
          <p>Communes sans bourgmestre</p>
        </div>
        <div class="card">
          <h3>{{ stats.totalAgents }}</h3>
          <p>Agents</p>
        </div>
      </section>
    </main>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "DashboardAdmin",
  data() {
    return {
      loading: true,
      showAgentsDemandes: false, // liens masqués pour l'instant
      stats: {
        totalCommunes: 0,
        communesAvecBourgmestre: 0,
        communesSansBourgmestre: 0,
        totalAgents: 0,
      },
    };
  },
  async mounted() {
    try {
      const token = localStorage.getItem("token");
      const response = await axios.get(
        "http://localhost:4000/api/dashboard/admin-general",
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );

      this.stats.totalCommunes = response.data.totalCommunes;
      this.stats.communesAvecBourgmestre =
        response.data.communesAvecBourgmestre;
      this.stats.communesSansBourgmestre =
        response.data.communesSansBourgmestre;
      this.stats.totalAgents = response.data.totalAgents;
    } catch (error) {
      console.error("Erreur chargement des stats", error);
    } finally {
      this.loading = false;
    }
  },
};
</script>

<style scoped>
.dashboard-layout {
  display: flex;
  font-family: "Roboto", sans-serif;
}
.sidebar {
  width: 250px;
  background: #003da5;
  color: white;
  min-height: 100vh;
  padding: 20px;
}
.sidebar h1 {
  font-size: 20px;
  margin-bottom: 24px;
}
.sidebar nav {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.sidebar a {
  color: white;
  text-decoration: none;
  font-weight: 500;
}
.sidebar a.router-link-active {
  background: white;
  color: #003da5;
  padding: 8px;
  border-radius: 4px;
}
.content {
  flex-grow: 1;
  padding: 32px;
  background: #f7f7f7;
}

/* Nouveau style logo */
.header-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.logo {
  max-height: 60px;
  object-fit: contain;
}

.cards {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}
.card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 200px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  text-align: center;
}
.card h3 {
  font-size: 28px;
  margin: 0;
  color: #003da5;
}
</style>