<template>
  <div class="dashboard">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Tableau de bord Agent</h1>
      </div>
      <div class="navbar-right">
        <!-- Boutons de navigation vers les pages demandes -->
        <router-link to="/demandes" class="nav-btn">📋 Toutes les demandes</router-link>
        <button @click="logout" class="logout-btn">🚪 Déconnexion</button>
      </div>
    </header>

    <!-- Statistiques -->
    <section class="stats">
      <div class="stat-card">
        <h2>{{ stats.totalDemandes }}</h2>
        <p>Demandes à traiter</p>
      </div>
      <div class="stat-card">
        <h2>{{ stats.demandesTraitees }}</h2>
        <p>Demandes traitées</p>
      </div>
    </section>

    <!-- Liste des dernières demandes -->
    <section class="demandes">
      <h3>Dernières demandes</h3>
      <table>
        <thead>
          <tr>
            <th>Type</th>
            <th>Citoyen</th>
            <th>Statut</th>
            <th>Date</th>
            <th>Détail</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="demande in demandes" :key="demande.id">
            <td>{{ getTypeDemandeLabel(demande.typeDemande) }}</td>
            <td>{{ formatNomComplet(demande.citoyen) }}</td>
            <td>{{ getStatutLabel(demande.statut.nom) }}</td>
            <td>{{ formatDate(demande.createdAt) }}</td>
            <td>
              <button @click="goToDetail(demande.id)" class="detail-btn">Voir</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "DashboardAgent",
  data() {
    return {
      stats: {
        totalDemandes: 0,
        demandesTraitees: 0,
      },
      demandes: [],
      selectedDemandeId: null,
    };
  },
  methods: {
    async fetchStats() {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get("http://localhost:4000/api/agents/dashboard", {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.stats = res.data;
      } catch (err) {
        console.error("Erreur chargement stats agent", err);
      }
    },
    async fetchDemandes() {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get("http://localhost:4000/api/agents/assigned-demandes", {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.demandes = res.data;
      } catch (err) {
        console.error("Erreur chargement demandes", err);
      }
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/login");
    },
    formatNomComplet(person) {
      if (!person) return "-";
      return [person.nom, person.prenom, person.postnom].filter(Boolean).join(" ");
    },
    getTypeDemandeLabel(type) {
      const mapping = {
        carte_identite: "Carte d'identité",
        acte_naissance: "Acte de naissance",
        acte_mariage: "Acte de mariage",
        acte_residence: "Acte de résidence",
      };
      return mapping[type] || type;
    },
    getStatutLabel(statut) {
      const mapping = {
        soumise: "Soumise",
        en_traitement: "En traitement",
        validee: "Validée",
      };
      return mapping[statut] || statut;
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString("fr-FR");
    },
    goToDetail(demandeId) {
      this.selectedDemandeId = demandeId;
      this.$router.push(`/demandes/${demandeId}`);
    },
  },
  async mounted() {
    await this.fetchStats();
    await this.fetchDemandes();
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
  align-items: center;
  gap: 10px;
}
.nav-btn {
  background: white;
  color: #003da5;
  padding: 8px 14px;
  border-radius: 6px;
  font-weight: bold;
  text-decoration: none;
  cursor: pointer;
}
.nav-btn:hover {
  background: #f1f1f1;
}
.logout-btn {
  background: white;
  color: #003da5;
  padding: 8px 14px;
  border-radius: 6px;
  font-weight: bold;
  border: none;
  cursor: pointer;
}
.logout-btn:hover {
  background: #f1f1f1;
}

/* Stats */
.stats {
  display: flex;
  gap: 20px;
  margin: 20px;
}
.stat-card {
  background: white;
  padding: 20px;
  border-radius: 10px;
  flex: 1;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
.stat-card h2 {
  font-size: 28px;
  color: #003da5;
}
.stat-card p {
  font-size: 14px;
  color: #666;
}

/* Table */
.demandes {
  margin: 20px;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th,
td {
  padding: 10px;
  border: 1px solid #ddd;
}
th {
  background: #003da5;
  color: white;
}
.detail-btn {
  background: #104b71;
  color: white;
  padding: 6px 12px;
  border-radius: 5px;
  border: none;
  cursor: pointer;
}
.detail-btn:hover {
  background: #0e2c5a;
}
</style>