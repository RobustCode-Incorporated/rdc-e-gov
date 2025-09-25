<template>
  <div class="page-demandes">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Gestion des Demandes</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/dashboard-bourgmestre" class="nav-btn">Accueil</router-link>
        <router-link to="/agents" class="nav-btn">Agents</router-link>
      </div>
    </header>

    <!-- Filtres -->
    <section class="filters">
      <input v-model="q" @input="applyFilters" placeholder="Rechercher par citoyen, type, commentaires..." />
      <label for="statut">Filtrer par statut :</label>
      <select v-model="filtreStatut" @change="applyFilters">
        <option value="">Toutes</option>
        <option value="soumise">Soumise</option>
        <option value="en_traitement">En traitement</option>
        <option value="validee">Validée</option>
      </select>
      <button @click="fetchDemandes">Rafraîchir</button>
    </section>

    <!-- Loading / Error -->
    <section v-if="loading" class="loading">Chargement des demandes...</section>
    <section v-else-if="error" class="error">⚠️ {{ error }}</section>

    <!-- Table des demandes -->
    <section v-else class="table-wrapper">
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
          <tr v-for="demande in pagedDemandes" :key="demande.id">
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
          <tr v-if="filteredDemandes.length === 0">
            <td colspan="6" class="empty">Aucune demande trouvée</td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div class="pagination" v-if="pages > 1">
        <button :disabled="page === 1" @click="page-- && applyFilters()">←</button>
        <span>Page {{ page }} / {{ pages }}</span>
        <button :disabled="page === pages" @click="page++ && applyFilters()">→</button>
      </div>
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
      q: "",
      statutMapping: {
        soumise: "Soumise",
        en_traitement: "En traitement",
        validee: "Validée",
      },
      error: null,
      page: 1,
      perPage: 10,
    };
  },
  computed: {
    filteredDemandes() {
      let arr = this.demandes.slice();

      if (this.filtreStatut) {
        arr = arr.filter(d => (d.statut && d.statut.nom ? d.statut.nom : d.statut) === this.filtreStatut);
      }

      if (this.q && this.q.trim()) {
        const q = this.q.toLowerCase();
        arr = arr.filter(d =>
          (d.citoyen && (
            (d.citoyen.nom || "").toLowerCase().includes(q) ||
            (d.citoyen.prenom || "").toLowerCase().includes(q)
          )) ||
          (d.typeDemande || "").toLowerCase().includes(q) ||
          (d.commentaires || "").toLowerCase().includes(q)
        );
      }

      return arr;
    },
    pages() {
      return Math.max(1, Math.ceil(this.filteredDemandes.length / this.perPage));
    },
    pagedDemandes() {
      const start = (this.page - 1) * this.perPage;
      return this.filteredDemandes.slice(start, start + this.perPage);
    }
  },
  methods: {
    async fetchDemandes() {
      this.loading = true;
      this.error = null;
      try {
        const token = localStorage.getItem("token");
        const url = "http://localhost:4000/api/demandes";
        const res = await axios.get(url, { headers: { Authorization: `Bearer ${token}` } });
        this.demandes = res.data;
        this.page = 1;
      } catch (err) {
        console.error("Erreur chargement demandes", err);
        this.error = "Impossible de charger les demandes.";
      } finally {
        this.loading = false;
      }
    },
    applyFilters() {
      if (this.page > this.pages) this.page = this.pages;
    },
    async validateDemande(id) {
      if (confirm("Êtes-vous sûr de vouloir valider et signer ce document ?")) {
        try {
          const token = localStorage.getItem("token");
          await axios.put(`http://localhost:4000/api/demandes/${id}/validate-document`, {}, {
            headers: { Authorization: `Bearer ${token}` },
          });
          alert("Demande validée et document signé avec succès !");
          this.fetchDemandes();
        } catch (err) {
          console.error("Erreur de validation:", err);
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

/* --- FILTERS --- */
.filters {
  margin: 24px 0;
  display: flex;
  align-items: center;
  gap: 12px;
}
.filters label { font-weight: 600; color: #003da5; }
.filters select, .filters input {
  padding: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
  min-width: 150px;
}

/* --- TABLE --- */
.table-wrapper {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
th, td {
  padding: 12px;
  text-align: left;
}
th {
  background: #003da5;
  color: white;
  font-weight: 600;
}
tr:nth-child(even) { background: #f7f7f7; }
button {
  border: none;
  border-radius: 6px;
  padding: 6px 12px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}
.validate-btn { background: #28a745; color: white; }
.validate-btn:hover { background: #218838; }
.view-btn { background: #104b71; color: white; }
.view-btn:hover { background: #0e2c5a; }
.document-link-cell {
  background: #007bff;
  color: white;
  padding: 4px 8px;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 600;
}
.document-link-cell:hover { background: #0056b3; }

/* --- LOADING / ERROR --- */
.loading { font-size: 18px; color: #003da5; margin-top: 16px; }
.error { font-size: 16px; color: red; background: #ffe6e6; padding: 10px; border-radius: 6px; margin-top: 16px; }

/* --- PAGINATION --- */
.pagination {
  margin-top: 12px;
  display: flex;
  gap: 8px;
  align-items: center;
}
</style>