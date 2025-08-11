<template>
  <div class="page-demandes-agent">
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Demandes à traiter</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/dashboard" class="nav-btn">🏠 Dashboard</router-link>
        <button @click="logout" class="logout-btn">🚪 Déconnexion</button>
      </div>
    </header>

    <section class="controls">
      <input v-model="q" @input="applyFilters" placeholder="Rechercher par citoyen, type..." />
      <select v-model="filterStatut" @change="applyFilters">
        <option value="">Tous statuts</option>
        <option v-for="s in statuts" :key="s.id" :value="s.id">{{ s.nom }}</option>
      </select>
      <button @click="fetchDemandes">Rafraîchir</button>
    </section>

    <section v-if="loading" class="loading">Chargement...</section>

    <section v-else>
      <table class="table-demandes">
        <thead>
          <tr>
            <th>Type</th>
            <th>Citoyen</th>
            <th>Statut</th>
            <th>Date</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="d in pagedDemandes" :key="d.id" v-if="d && d.id">
            <td>{{ typeLabel(d.typeDemande) }}</td>
            <td>{{ fullname(d.citoyen || {}) }}</td>
            <td>{{ d.statut && d.statut.nom ? d.statut.nom : '—' }}</td>
            <td>{{ formatDate(d.createdAt) }}</td>
            <td>
              <button @click="openDetails(d.id)">Voir / Traiter</button>
            </td>
          </tr>
          <tr v-if="!demandes.length">
            <td colspan="5" class="empty">Aucune demande trouvée</td>
          </tr>
        </tbody>
      </table>

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
  name: "DemandesAgent",
  data() {
    return {
      loading: true,
      demandes: [],
      statuts: [],
      q: "",
      filterStatut: "",
      page: 1,
      perPage: 10,
    };
  },
  computed: {
    filteredDemandes() {
      let arr = this.demandes.slice();

      if (this.filterStatut) {
        arr = arr.filter(d => String(d.statutId) === String(this.filterStatut));
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
    formatDate(d) {
      return d ? new Date(d).toLocaleString("fr-FR") : "-";
    },
    fullname(person) {
      if (!person) return "-";
      return [person.nom || "", person.prenom || "", person.postnom || ""].filter(Boolean).join(" ");
    },
    typeLabel(t) {
      const map = {
        carte_identite: "Carte d'identité",
        acte_naissance: "Acte de naissance",
        acte_mariage: "Acte de mariage",
        acte_residence: "Acte de résidence"
      };
      return map[t] || t;
    },
    async fetchStatuts() {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get("http://localhost:4000/api/statuts", {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.statuts = res.data;
      } catch (err) {
        console.error("Erreur statuts:", err);
      }
    },
    async fetchDemandes() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get("http://localhost:4000/api/agents/assigned-demandes", {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log("Demandes reçues :", res.data);
        this.demandes = res.data.filter(d => d && d.id);
        this.page = 1;
      } catch (err) {
        console.error("Erreur chargement demandes:", err);
        alert("Erreur chargement demandes.");
      } finally {
        this.loading = false;
      }
    },
    applyFilters() {
      if (this.page > this.pages) this.page = this.pages;
    },
    openDetails(id) {
      if (!id) {
        console.warn("ID invalide passé à openDetails:", id);
        alert("Impossible d’ouvrir le détail : ID invalide.");
        return;
      }
      this.$router.push({ name: "DemandeDetailsAgent", params: { id } });
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push({ name: "LoginAgent" });
    }
  },
  async mounted() {
    await Promise.all([this.fetchStatuts(), this.fetchDemandes()]);
  }
};
</script>

<style scoped>
.page-demandes-agent {
  font-family: "Inter", sans-serif;
  padding: 20px;
}
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #003da5;
  color: #fff;
  padding: 10px 16px;
  border-radius: 6px;
  flex-wrap: wrap;
}
.navbar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo {
  height: 36px;
  display: block;
}
.navbar-right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: nowrap;
}
.nav-btn {
  color: #fff;
  text-decoration: none;
  background: #104b71;
  padding: 6px 12px;
  border-radius: 6px;
  font-weight: 600;
  transition: background 0.3s ease;
}
.nav-btn:hover {
  background: #0a3350;
}
.logout-btn {
  background: #d9534f;
  border: none;
  color: #fff;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  transition: background 0.3s ease;
}
.logout-btn:hover {
  background: #b52b27;
}
.controls {
  margin: 16px 0;
  display: flex;
  gap: 10px;
  align-items: center;
}
input {
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #ccc;
}
select {
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #ccc;
}
.table-demandes {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}
.table-demandes th,
.table-demandes td {
  border: 1px solid #e3e3e3;
  padding: 10px;
  text-align: left;
}
.table-demandes th {
  background: #003da5;
  color: #fff;
}
button {
  background: #003da5;
  color: #fff;
  border: none;
  padding: 6px 10px;
  border-radius: 6px;
  cursor: pointer;
}
.empty {
  text-align: center;
  color: #666;
}
.pagination {
  margin-top: 12px;
  display: flex;
  gap: 8px;
  align-items: center;
}
</style>