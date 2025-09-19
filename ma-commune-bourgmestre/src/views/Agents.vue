<template>
  <div class="page-agents">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Gestion des Agents</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/dashboard-bourgmestre" class="nav-btn">Accueil</router-link>
        <router-link to="/demandes" class="nav-btn">Demandes</router-link>
      </div>
    </header>

    <!-- Loading -->
    <section v-if="loading" class="loading">Chargement des agents...</section>

    <!-- Table des agents -->
    <section v-else class="table-wrapper">
      <h2>Liste des Agents</h2>
      <table>
        <thead>
          <tr>
            <th>Nom complet</th>
            <th>Nom d'utilisateur</th>
            <th>Type de demande</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="agent in agents" :key="agent.id">
            <td>{{ formatNomComplet(agent) }}</td>
            <td>{{ agent.username }}</td>
            <td>{{ getTypeDemandeLabel(agent.typeDemande) }}</td>
            <td>
              <button class="delete-btn" @click="deleteAgent(agent.id)">🗑 Supprimer</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- Formulaire ajout agent -->
    <section class="form-section">
      <h2>Ajouter un nouvel Agent</h2>
      <form @submit.prevent="createAgent">
        <div class="form-group">
          <label>Nom</label>
          <input v-model="form.nom" required />
        </div>
        <div class="form-group">
          <label>Prénom</label>
          <input v-model="form.prenom" required />
        </div>
        <div class="form-group">
          <label>Postnom</label>
          <input v-model="form.postnom" />
        </div>
        <div class="form-group">
          <label>Nom d'utilisateur</label>
          <input v-model="form.username" required />
        </div>
        <div class="form-group">
          <label>Mot de passe</label>
          <input type="password" v-model="form.password" required />
        </div>
        <div class="form-group">
          <label>Type de demande</label>
          <select v-model="form.typeDemande" required>
            <option disabled value="">-- Sélectionner --</option>
            <option value="carte_identite">Carte d'identité</option>
            <option value="acte_naissance">Acte de naissance</option>
            <option value="acte_mariage">Acte de mariage</option>
            <option value="acte_residence">Acte de résidence</option>
          </select>
        </div>
        <button type="submit" class="add-btn">Ajouter</button>
      </form>
    </section>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "Agents",
  data() {
    return {
      loading: true,
      agents: [],
      form: {
        nom: "",
        prenom: "",
        postnom: "",
        username: "",
        password: "",
        typeDemande: "",
      },
      error: null,
    };
  },
  methods: {
    async fetchAgents() {
      this.loading = true;
      this.error = null;
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get("http://localhost:4000/api/agents", {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.agents = res.data;
      } catch (err) {
        console.error("Erreur chargement agents", err);
        this.error = "Impossible de charger les agents.";
      } finally {
        this.loading = false;
      }
    },
    async createAgent() {
      try {
        const token = localStorage.getItem("token");
        await axios.post("http://localhost:4000/api/agents", this.form, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert("Agent ajouté avec succès !");
        this.form = { nom: "", prenom: "", postnom: "", username: "", password: "", typeDemande: "" };
        this.fetchAgents();
      } catch (err) {
        console.error("Erreur ajout agent", err);
        alert("Erreur lors de l'ajout de l'agent.");
      }
    },
    async deleteAgent(id) {
      if (!confirm("Voulez-vous vraiment supprimer cet agent ?")) return;
      try {
        const token = localStorage.getItem("token");
        await axios.delete(`http://localhost:4000/api/agents/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert("Agent supprimé !");
        this.fetchAgents();
      } catch (err) {
        console.error("Erreur suppression agent", err);
        alert("Erreur lors de la suppression.");
      }
    },
    formatNomComplet(agent) {
      return [agent.nom, agent.prenom, agent.postnom].filter(Boolean).join(" ");
    },
    getTypeDemandeLabel(value) {
      const mapping = {
        carte_identite: "Carte d'identité",
        acte_naissance: "Acte de naissance",
        acte_mariage: "Acte de mariage",
        acte_residence: "Acte de résidence",
      };
      return mapping[value] || value;
    },
  },
  mounted() {
    this.fetchAgents();
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

/* --- TABLE --- */
.table-wrapper { overflow-x: auto; margin-top: 20px; }
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
th { background: #003da5; color: white; font-weight: 600; }
tr:nth-child(even) { background: #f7f7f7; }
button { border: none; border-radius: 6px; padding: 6px 12px; cursor: pointer; font-weight: 600; transition: all 0.2s ease; }
.delete-btn { background: #db3832; color: white; }
.delete-btn:hover { background: #b52b26; }

/* --- FORMULAIRE --- */
.form-section {
  background: white;
  padding: 20px;
  border-radius: 10px;
  margin-top: 30px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
  max-width: 600px;
}
.form-group { margin-bottom: 16px; }
label { display: block; font-weight: 600; margin-bottom: 6px; color: #003da5; }
input, select {
  width: 100%;
  padding: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
}
.add-btn { background: #104b71; color: white; width: 100%; padding: 10px; border-radius: 6px; margin-top: 10px; }
.add-btn:hover { background: #0e2c5a; }

/* --- LOADING / ERROR --- */
.loading { font-size: 18px; color: #003da5; margin-top: 16px; }
.error { font-size: 16px; color: red; background: #ffe6e6; padding: 10px; border-radius: 6px; margin-top: 16px; }
</style>