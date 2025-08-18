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
            <th>Document</th>
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
              <a v-if="demande.documentPath"
                 :href="`http://localhost:4000/documents/${demande.documentPath}`"
                 target="_blank"
                 class="document-link-cell">
                📥 Voir
              </a>
              <span v-else>N/A</span>
            </td>
            <td>
              <button
                v-if="demande.statut && demande.statut.nom === 'en_traitement'"
                @click="validateDemande(demande.id)"
                class="validate-btn"
              >
                Valider et Signer
              </button>
              <button
                v-else
                @click="goToDemandeDetails(demande.id)"
                class="view-btn"
              >
                Voir la demande
              </button>
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
    async validateDemande(id) {
      if (confirm("Êtes-vous sûr de vouloir valider et signer ce document ?")) {
        try {
          const token = localStorage.getItem("token");
          await axios.put(`http://localhost:4000/api/demandes/${id}/validate-document`, {}, {
            headers: { Authorization: `Bearer ${token}` },
          });
          alert("Demande validée et document signé avec succès !");
          this.fetchDemandes(); // Rafraîchir la liste
        } catch (error) {
          console.error("Erreur de validation:", error.response?.data);
          alert("Erreur lors de la validation. Le document doit être 'en traitement'.");
        }
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
      const statutNom = statut && statut.nom ? statut.nom : statut;
      return this.statutMapping[statutNom] || statutNom;
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString("fr-FR");
    },
    goToDemandeDetails(id) {
      this.$router.push({ name: 'DemandeDetailsAdmin', params: { id } });
    },
  },
  mounted() {
    this.fetchDemandes();
  },
};
</script>

<style scoped>
/* Styles existants pour .page-demandes */
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
.validate-btn {
  background: #28a745;
}
.validate-btn:hover {
  background: #218838;
}
.view-btn {
  background: #104b71;
}
.view-btn:hover {
  background: #0e2c5a;
}
.document-link-cell {
  background: #007bff;
  color: white;
  padding: 5px 8px;
  border-radius: 4px;
  text-decoration: none;
}
.document-link-cell:hover {
  background: #0056b3;
}

</style>