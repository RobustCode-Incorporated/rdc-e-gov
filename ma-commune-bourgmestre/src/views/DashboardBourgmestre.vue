<template>
  <div class="dashboard-bourgmestre">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Administrateur de Commune</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/agents" class="nav-btn">Agents</router-link>
        <router-link to="/demandes" class="nav-btn">Demandes</router-link>
        <button @click="logout" class="logout-btn">Déconnexion</button>
      </div>
    </header>

    <main class="content">
      <h2>Statistiques de la commune</h2>

      <section v-if="loading" class="loading">Chargement des statistiques...</section>
      <section v-else-if="error" class="error">⚠️ {{ error }}</section>

      <!-- Cartes statistiques -->
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
        <div class="card">
          <h3>{{ stats.totalCitoyens }}</h3>
          <p>Citoyens</p>
        </div>
      </section>

      <!-- Donuts population -->
      <section class="charts" v-if="stats.totalCitoyens > 0">
        <div class="chart-card" v-if="genderData.datasets[0].data.some(v => v > 0)">
          <h3>Répartition Hommes / Femmes</h3>
          <div class="donut-wrapper">
            <Doughnut :key="genderChartKey" :data="genderData" :options="chartOptions" />
          </div>
        </div>

        <div class="chart-card" v-if="ageData.datasets[0].data.some(v => v > 0)">
          <h3>Répartition par tranches d'âge</h3>
          <div class="donut-wrapper">
            <Doughnut :key="ageChartKey" :data="ageData" :options="chartOptions" />
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script>
import axios from "axios";
import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement } from "chart.js";
import { Doughnut } from "vue-chartjs";

ChartJS.register(Title, Tooltip, Legend, ArcElement);

export default {
  name: "DashboardBourgmestre",
  components: { Doughnut },
  data() {
    return {
      loading: true,
      error: null,
      genderChartKey: 0,
      ageChartKey: 0,
      stats: {
        totalDemandes: 0,
        demandesSoumises: 0,
        demandesEnTraitement: 0,
        demandesValidees: 0,
        totalAgents: 0,
        totalCitoyens: 0,
        hommes: 0,
        femmes: 0,
        jeunes: 0,
        adultes: 0,
        seniors: 0,
      },
      genderData: {
        labels: ["Hommes", "Femmes"],
        datasets: [
          {
            data: [0, 0],
            backgroundColor: ["#003da5", "#db3832"],
            borderWidth: 2,
          },
        ],
      },
      ageData: {
        labels: ["Jeunes (0-17)", "Adultes (18-59)", "Seniors (60+)"],
        datasets: [
          {
            data: [0, 0, 0],
            backgroundColor: ["#4caf50", "#ff9800", "#9c27b0"],
            borderWidth: 2,
          },
        ],
      },
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: "60%",
        plugins: { legend: { position: "bottom" } },
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
          { headers: { Authorization: `Bearer ${token}` } }
        );

        // Mettre à jour les statistiques
        this.stats = {
          ...this.stats,
          totalDemandes: res.data.totalDemandes || 0,
          demandesSoumises: res.data.demandesSoumises || 0,
          demandesEnTraitement: res.data.demandesEnTraitement || 0,
          demandesValidees: res.data.demandesValidees || 0,
          totalAgents: res.data.totalAgents || 0,
          totalCitoyens: res.data.totalCitoyens || 0,
          hommes: res.data.hommes || 0,
          femmes: res.data.femmes || 0,
          jeunes: res.data.jeune || 0,
          adultes: res.data.adulte || 0,
          seniors: res.data.senior || 0,
        };

        // Mettre à jour les donuts et forcer le rerender
        this.genderData.datasets[0].data = [this.stats.hommes, this.stats.femmes];
        this.ageData.datasets[0].data = [this.stats.jeunes, this.stats.adultes, this.stats.seniors];
        this.genderChartKey++;
        this.ageChartKey++;

      } catch (err) {
        console.error("Erreur chargement stats bourgmestre", err);
        this.error = "Impossible de charger les statistiques.";
      } finally {
        this.loading = false;
      }
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/");
    },
  },
  async mounted() {
    await this.fetchStats();
  },
};
</script>

<style scoped>
/* --- NAVBAR --- */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #003da5;
  padding: 12px 24px;
  color: white;
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}
.navbar-left { display: flex; align-items: center; gap: 12px; }
.logo { height: 42px; }
.navbar-right { display: flex; gap: 14px; }
.nav-btn {
  background: white;
  color: #003da5;
  padding: 8px 16px;
  border-radius: 6px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
}
.nav-btn:hover { background: #f1f1f1; transform: translateY(-2px); }
.logout-btn {
  background: #db3832;
  color: white;
  padding: 8px 16px;
  border-radius: 6px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}
.logout-btn:hover { background: #b52b26; transform: translateY(-2px); }

/* --- CONTENU --- */
.content {
  padding: 32px;
  font-family: "Roboto", sans-serif;
  background: #f7f7f7;
  min-height: calc(100vh - 70px);
}

/* --- CARTES STATISTIQUES --- */
.cards {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-top: 20px;
  justify-content: center;
}
.card {
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 220px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
  text-align: center;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}
.card h3 { font-size: 28px; margin: 0; color: #003da5; }

/* --- LOADING / ERROR --- */
.loading { font-size: 18px; color: #003da5; }
.error { font-size: 16px; color: red; background: #ffe6e6; padding: 10px; border-radius: 6px; }

/* --- CHARTS --- */
.charts {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-top: 40px;
  justify-content: center;
}
.chart-card {
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 400px;
  max-width: 100%;
  height: 350px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
}
.chart-card h3 {
  margin-bottom: 16px;
  color: #003da5;
  text-align: center;
}
.donut-wrapper {
  width: 100%;
  height: 300px;
}
</style>