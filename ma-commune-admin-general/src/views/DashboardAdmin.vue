<template>
  <div class="dashboard-admin">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
        <h1>Administrateur Général</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/communes" class="nav-btn">Communes</router-link>
        <router-link to="/administrateurs" class="nav-btn">Bourgmestres</router-link>
        <router-link v-if="showAgentsDemandes" to="/agents" class="nav-btn">Agents</router-link>
        <router-link v-if="showAgentsDemandes" to="/demandes" class="nav-btn">Demandes</router-link>
        <button @click="logout" class="logout-btn">Déconnexion</button>
      </div>
    </header>

    <!-- Contenu principal -->
    <main class="content">
      <h2>Statistiques Globales</h2>

      <section v-if="loading" class="loading">Chargement...</section>

      <!-- Cartes -->
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
        <div class="card">
          <h3>{{ stats.totalCitoyens }}</h3>
          <p>Citoyens</p>
        </div>
      </section>

      <!-- Donuts -->
      <section class="charts">
        <div class="chart-card" v-if="genderData.datasets[0].data.some(v => v > 0)">
          <h3>Répartition Hommes / Femmes</h3>
          <div class="donut-wrapper">
            <Doughnut :data="genderData" :options="chartOptions" />
          </div>
        </div>

        <div class="chart-card" v-if="ageData.datasets[0].data.some(v => v > 0)">
          <h3>Répartition par tranches d'âge</h3>
          <div class="donut-wrapper">
            <Doughnut :data="ageData" :options="chartOptions" />
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
  name: "DashboardAdmin",
  components: { Doughnut },
  data() {
    return {
      loading: true,
      showAgentsDemandes: false,
      stats: {
        totalCommunes: 0,
        communesAvecBourgmestre: 0,
        communesSansBourgmestre: 0,
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
            backgroundColor: ["#003da5", "#db3832"], // bleu et rouge
          },
        ],
      },
      ageData: {
        labels: ["Jeunes (0-17)", "Adultes (18-59)", "Seniors (60+)"],
        datasets: [
          {
            data: [0, 0, 0],
            backgroundColor: ["#4caf50", "#ff9800", "#9c27b0"], // vert, orange, violet
          },
        ],
      },
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: "60%",
        plugins: {
          legend: { position: "bottom" },
        },
      },
    };
  },
  methods: {
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/");
    },
    async fetchStats() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");

        // Statistiques globales
        const resGlobal = await axios.get(
          "http://localhost:4000/api/dashboard/admin-general",
          { headers: { Authorization: `Bearer ${token}` } }
        );

        this.stats.totalCommunes = resGlobal.data.totalCommunes;
        this.stats.communesAvecBourgmestre = resGlobal.data.communesAvecBourgmestre;
        this.stats.communesSansBourgmestre = resGlobal.data.communesSansBourgmestre;
        this.stats.totalAgents = resGlobal.data.totalAgents;

        // Statistiques population
        const resCitoyens = await axios.get(
          "http://localhost:4000/api/dashboard/population",
          { headers: { Authorization: `Bearer ${token}` } }
        );

        this.stats.totalCitoyens = resCitoyens.data.totalPopulation || 0;
        this.stats.hommes = resCitoyens.data.hommes || 0;
        this.stats.femmes = resCitoyens.data.femmes || 0;
        this.stats.jeunes = resCitoyens.data.jeune || 0;
        this.stats.adultes = resCitoyens.data.adulte || 0;
        this.stats.seniors = resCitoyens.data.senior || 0;

        // Mise à jour des donuts
        this.genderData.datasets[0].data = [this.stats.hommes, this.stats.femmes];
        this.ageData.datasets[0].data = [this.stats.jeunes, this.stats.adultes, this.stats.seniors];
        this.genderChartKey++;
      } catch (error) {
        console.error("Erreur chargement des stats", error);
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
/* NAVBAR */
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

/* CONTENT */
.content {
  padding: 32px;
  font-family: "Roboto", sans-serif;
  background: #f7f7f7;
  min-height: calc(100vh - 70px);
}
.cards {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
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
.card h3 {
  font-size: 28px;
  margin: 0;
  color: #003da5;
}
.loading {
  font-size: 18px;
  color: #003da5;
}

/* CHARTS */
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
  height: 400px;
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