<template>
    <div class="page-demande-details">
      <header class="navbar">
        <div class="navbar-left">
          <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
          <h1>Détail demande</h1>
        </div>
        <div class="navbar-right">
          <router-link to="/agent/demandes" class="nav-btn">← Retour</router-link>
        </div>
      </header>
  
      <section v-if="loading" class="loading">Chargement...</section>
  
      <section v-else class="card">
        <h2>{{ typeLabel(demande.typeDemande) }}</h2>
  
        <div class="row"><strong>Citoyen :</strong> {{ fullname(demande.citoyen) }}</div>
        <div class="row"><strong>Date :</strong> {{ formatDate(demande.createdAt) }}</div>
        <div class="row"><strong>Statut actuel :</strong> {{ demande.statut?.nom || '—' }}</div>
  
        <h3>Données fournies</h3>
        <pre class="donnees">{{ prettyJson(demande.donneesJson) }}</pre>
  
        <h3>Commentaires</h3>
        <p v-if="demande.commentaires">{{ demande.commentaires }}</p>
        <p v-else class="muted">Aucun commentaire</p>
  
        <hr />
  
        <div class="form-row">
          <label>Changer le statut</label>
          <select v-model="selectedStatut">
            <option value="">-- Choisir --</option>
            <option v-for="s in statuts" :key="s.id" :value="s.id">{{ s.nom }}</option>
          </select>
        </div>
  
        <div class="form-row">
          <label>Ajouter un commentaire</label>
          <textarea v-model="comment" rows="3" placeholder="Votre commentaire..."></textarea>
        </div>
  
        <div class="actions">
          <button @click="updateDemande" :disabled="updating">Enregistrer</button>
          <button @click="refresh" class="ghost">Rafraîchir</button>
        </div>
      </section>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    name: "DemandeDetailsAgent",
    data() {
      return {
        loading: true,
        updating: false,
        demande: null,
        statuts: [],
        selectedStatut: "",
        comment: ""
      };
    },
    methods: {
      formatDate(d) {
        return d ? new Date(d).toLocaleString("fr-FR") : "-";
      },
      fullname(person) {
        if (!person) return "-";
        return [person.nom, person.prenom, person.postnom].filter(Boolean).join(" ");
      },
      prettyJson(raw) {
        if (!raw) return "{}";
        try {
          const parsed = typeof raw === "string" ? JSON.parse(raw) : raw;
          return JSON.stringify(parsed, null, 2);
        } catch {
          return String(raw);
        }
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
          console.error("Erreur chargement statuts:", err);
        }
      },
  
      async fetchDemande() {
        this.loading = true;
        try {
          const token = localStorage.getItem("token");
          const res = await axios.get(`http://localhost:4000/api/demandes/${this.$route.params.id}`, {
            headers: { Authorization: `Bearer ${token}` }
          });
          this.demande = res.data;
          this.selectedStatut = this.demande.statutId || "";
          this.comment = this.demande.commentaires || "";
        } catch (err) {
          console.error("Erreur chargement demande:", err);
          alert("Impossible de charger la demande.");
        } finally {
          this.loading = false;
        }
      },
  
      async updateDemande() {
        if (!this.selectedStatut && !this.comment) {
          alert("Rien à mettre à jour.");
          return;
        }
  
        this.updating = true;
        try {
          const token = localStorage.getItem("token");
          const payload = {};
          if (this.selectedStatut) payload.statutId = this.selectedStatut;
          if (this.comment !== undefined) payload.commentaires = this.comment;
  
          await axios.put(`http://localhost:4000/api/demandes/${this.demande.id}`, payload, {
            headers: { Authorization: `Bearer ${token}` }
          });
  
          alert("Mise à jour enregistrée.");
          await this.fetchDemande();
        } catch (err) {
          console.error("Erreur mise à jour demande:", err);
          alert("Erreur lors de la mise à jour.");
        } finally {
          this.updating = false;
        }
      },
  
      refresh() {
        this.fetchDemande();
      }
    },
    async mounted() {
      await Promise.all([this.fetchStatuts(), this.fetchDemande()]);
    }
  };
  </script>
  
  <style scoped>
  .page-demande-details { padding:20px; font-family:Inter, sans-serif; }
  .navbar { display:flex; justify-content:space-between; align-items:center; background:#003da5; color:#fff; padding:10px; border-radius:6px; }
  .logo { height:36px; }
  .card { background:#fff; padding:16px; border-radius:8px; margin-top:16px; box-shadow:0 1px 6px rgba(0,0,0,0.08); }
  .row { margin:6px 0; }
  .donnees { background:#f8f8f8; padding:10px; border-radius:6px; max-height:300px; overflow:auto; }
  .form-row { margin:12px 0; display:flex; flex-direction:column; gap:8px; }
  textarea { resize:vertical; padding:8px; border-radius:6px; border:1px solid #ddd; }
  .actions { display:flex; gap:8px; margin-top:10px; }
  button { background:#003da5; color:#fff; padding:8px 12px; border-radius:6px; border:none; cursor:pointer; }
  button.ghost { background:#eee; color:#333; }
  </style>