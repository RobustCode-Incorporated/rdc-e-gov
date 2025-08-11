<template>
  <div class="dashboard-bourgmestre">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Bourgmestre - Tableau de bord</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/agents" class="nav-btn">👥 Agents</router-link>
        <router-link to="/demandes" class="nav-btn">📄 Demandes</router-link>
      </div>
    </header>

    <!-- Contenu principal -->
    <main class="content">
      <h2>📊 Statistiques de ma commune</h2>

      <section v-if="loading" class="loading">
        Chargement des statistiques...
      </section>

      <section v-else-if="error" class="error">
        ⚠️ {{ error }}
      </section>

      <section v-else class="cards">
        <div class="card">
          <h3>{{ stats.totalDemandes }}</h3>
          <p>Demandes totales</p>
        </div>
        <div class="card">
          <h3>{{ stats.demandesSoumises }}</h3>
          <p>Soumises</p>
        </div>
        <div class="card">
          <h3>{{ stats.demandesEnTraitement }}</h3>
          <p>En traitement</p>
        </div>
        <div class="card">
          <h3>{{ stats.demandesValidees }}</h3>
          <p>Validées</p>
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
  name: "DashboardBourgmestre",
  data() {
    return {
      loading: true,
      error: null,
      stats: {
        totalDemandes: 0,
        demandesSoumises: 0,
        demandesEnTraitement: 0,
        demandesValidees: 0,
        totalAgents: 0,
      },
    };
  },
  methods: {
    async fetchStats() {
      this.loading = true;
      this.error = null;
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get(
          "http://localhost:4000/api/dashboard/bourgmestre",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        this.stats = res.data;
      } catch (err) {
        console.error("Erreur chargement stats bourgmestre", err);
        this.error = "Impossible de charger les statistiques.";
      } finally {
        this.loading = false;
      }
    },
  },
  async mounted() {
    await this.fetchStats();
  },
};
</script>

<style scoped>
/* Navbar */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #003da5;
  padding: 10px 20px;
  color: white;
}
.navbar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo {
  height: 40px;
}
.navbar-right {
  display: flex;
  gap: 12px;
}
.nav-btn {
  background: white;
  color: #003da5;
  padding: 8px 14px;
  border-radius: 6px;
  font-weight: bold;
  text-decoration: none;
}
.nav-btn:hover {
  background: #f1f1f1;
}

/* Contenu principal */
.content {
  padding: 20px;
  font-family: "Roboto", sans-serif;
}
.cards {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-top: 20px;
}
.card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 180px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  text-align: center;
}
.card h3 {
  font-size: 26px;
  margin: 0;
  color: #003da5;
}
.loading {
  font-size: 18px;
}
.error {
  font-size: 16px;
  color: red;
  background: #ffe6e6;
  padding: 10px;
  border-radius: 6px;
}
</style>