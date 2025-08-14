<template>
  <div class="page-demandes">
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Gestion des Demandes</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/dashboard-bourgmestre" class="nav-btn">🏠 Dashboard</router-link>
        <router-link to="/agents" class="nav-btn">🛡️ Agents</router-link>
      </div>
    </header>

    <section class="filters">
      <label for="statut">Filtrer par statut :</label>
      <select v-model="filtreStatut" @change="fetchDemandes">
        <option value="">Toutes</option>
        <option value="soumise">Soumise</option>
        <option value="en_traitement">En traitement</option>
        <option value="validee">Validée</option>
      </select>
    </section>

    <section v-if="loading" class="loading">Chargement des demandes...</section>

    <section v-else>
      <table>
        <thead>
          <tr>
            <th>Type de demande</th>
            <th>Citoyen</th>
            <th>Date</th>
            <th>Statut</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="demande in demandes" :key="demande.id">
            <td>{{ getTypeDemandeLabel(demande.typeDemande) }}</td>
            <td>{{ formatNomComplet(demande.citoyen) }}</td>
            <td>{{ formatDate(demande.createdAt) }}</td>
            <td>{{ getStatutLabel(demande.statut) }}</td>
            <td>
              <button @click="goToDemandeDetails(demande.id)">Voir la demande</button>
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
  name: "Demandes",
  data() {
    return {
      loading: true,
      demandes: [],
      filtreStatut: "",
      statutMapping: {
        soumise: "Soumise",
        en_traitement: "En traitement",
        validee: "Validée",
      },
    };
  },
  methods: {
    async fetchDemandes() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");
        let url = "http://localhost:4000/api/demandes";
        if (this.filtreStatut) {
          url += `?statut=${this.filtreStatut}`;
        }
        const res = await axios.get(url, {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.demandes = res.data;
      } catch (error) {
        console.error("Erreur chargement demandes", error);
      } finally {
        this.loading = false;
      }
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
      // Vérifie si le statut est un objet (avec un nom) ou une simple chaîne de caractères
      const statutNom = statut && statut.nom ? statut.nom : statut;
      return this.statutMapping[statutNom] || statutNom;
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString("fr-FR");
    },
    goToDemandeDetails(id) {
      // Redirige l'utilisateur vers la page de détails de la demande en passant l'ID
      this.$router.push({ name: 'DemandeDetailsAdmin', params: { id } });
    },
  },
  mounted() {
    // Appel de la fonction de chargement des données au moment où le composant est monté
    this.fetchDemandes();
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

/* Filters */
.filters {
  margin: 20px 0;
}
.filters label {
  font-weight: bold;
  margin-right: 10px;
}
.filters select {
  padding: 6px;
  border-radius: 4px;
}

/* Table */
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}
th,
td {
  border: 1px solid #ddd;
  padding: 10px;
}
th {
  background: #003da5;
  color: white;
}
button {
  background: #104b71;
  color: white;
  padding: 6px 12px;
  border-radius: 5px;
  border: none;
  cursor: pointer;
}
button:hover {
  background: #0e2c5a;
}
</style>