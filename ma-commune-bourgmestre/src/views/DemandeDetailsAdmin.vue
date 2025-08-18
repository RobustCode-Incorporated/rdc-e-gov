<template>
  <div class="page-demande-details-admin">
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Détails de la Demande</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/demandes" class="nav-btn">📋 Toutes les demandes</router-link>
      </div>
    </header>

    <section v-if="loading" class="loading">
      Chargement des détails de la demande...
    </section>

    <section v-else-if="!demande" class="empty-state">
      Demande non trouvée.
    </section>

    <section v-else class="demande-details-card">
      <div class="details-header">
        <h2>Demande pour : {{ formatNomComplet(demande.citoyen) }}</h2>
        <span class="demande-statut" :class="getStatutClass(demande.statut)">
          Statut : {{ getStatutLabel(demande.statut) }}
        </span>
      </div>

      <div class="details-body">
        <p><strong>Type de demande :</strong> {{ getTypeDemandeLabel(demande.typeDemande) }}</p>
        <p><strong>Date de soumission :</strong> {{ formatDate(demande.createdAt) }}</p>
        <p v-if="demande.agent">
          <strong>Agent assigné :</strong> {{ formatNomComplet(demande.agent) }}
        </p>
        <div class="commentaires-section">
          <h3>Commentaires de l'agent :</h3>
          <p v-if="demande.commentaires">{{ demande.commentaires }}</p>
          <p v-else>Aucun commentaire.</p>
        </div>
      </div>

      <div class="details-actions">
        <button 
          v-if="demande.statut && demande.statut.nom === 'en traitement'" 
          @click="validateDemande"
          :disabled="isUpdating"
          class="validate-button"> <!-- Ajout d'une classe pour le style -->
          <span v-if="isUpdating">Validation en cours...</span>
          <span v-else>Valider et signer le document</span>
        </button>

        <a 
          v-if="demande.documentPath"
          :href="`http://localhost:4000/documents/${demande.documentPath.split('/').pop()}`"
          target="_blank"
          class="view-document-link"> <!-- Ajout d'une classe pour le style -->
          📥 Voir le Document
        </a>
        
        <button @click="goBack" class="back-btn">Retour à la liste</button>
      </div>
    </section>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "DemandeDetailsAdmin",
  data() {
    return {
      loading: true,
      isUpdating: false,
      demande: null,
      statutMapping: {
        soumise: "Soumise",
        "en traitement": "En traitement", // Corrigé pour correspondre à la DB
        validee: "Validée",
      },
    };
  },
  methods: {
    async fetchDemandeDetails() {
      this.loading = true;
      try {
        const id = this.$route.params.id;
        const token = localStorage.getItem("token");
        const res = await axios.get(`http://localhost:4000/api/demandes/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.demande = res.data;
      } catch (error) {
        console.error("Erreur chargement des détails:", error);
        this.demande = null;
      } finally {
        this.loading = false;
      }
    },
    async validateDemande() {
      this.isUpdating = true;
      try {
        const id = this.$route.params.id;
        const token = localStorage.getItem("token");
        const res = await axios.put(
          `http://localhost:4000/api/demandes/${id}/validate-document`,
          {},
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        alert(res.data.message);
        // Rafraîchir complètement les données de la demande pour obtenir le nouveau documentPath et le statut
        await this.fetchDemandeDetails(); 
      } catch (error) {
        console.error("Erreur de validation:", error.response?.data || error.message);
        alert("Erreur lors de la validation et de la signature du document.");
      } finally {
        this.isUpdating = false;
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
    getStatutClass(statut) {
      const statutNom = statut && statut.nom ? statut.nom : statut;
      // Normaliser le nom pour les classes CSS si nécessaire (remplacer les espaces par des underscores)
      const cssClassNom = statutNom ? statutNom.replace(/\s+/g, '_') : '';
      return `statut-${cssClassNom}`;
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString("fr-FR");
    },
    goBack() {
      this.$router.go(-1);
    },
  },
  mounted() {
    this.fetchDemandeDetails();
  },
};
</script>

<style scoped>
.page-demande-details-admin {
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
}
.navbar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo {
  height: 36px;
}
.navbar-right .nav-btn {
  background: white;
  color: #003da5;
  padding: 8px 14px;
  border-radius: 6px;
  font-weight: bold;
  text-decoration: none;
  transition: background 0.3s ease;
}
.navbar-right .nav-btn:hover {
  background: #f1f1f1;
}
.demande-details-card {
  background: #fff;
  padding: 24px;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin-top: 20px;
}
.details-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.details-header h2 {
  font-size: 24px;
  color: #003da5;
  margin: 0;
}
.demande-statut {
  font-weight: bold;
  padding: 6px 12px;
  border-radius: 15px;
  color: white; /* Assurer que le texte est lisible sur les fonds colorés */
}
.statut-soumise {
  background-color: #f0ad4e;
}
.statut-en_traitement { /* Utilisera ceci si le nom est "en traitement" */
  background-color: #003da5;
}
.statut-validee {
  background-color: #28a745;
}
.details-body {
  margin-bottom: 20px;
  border-top: 1px solid #eee;
  padding-top: 20px;
}
.details-body p {
  margin: 8px 0;
  color: #333;
}
.commentaires-section {
  margin-top: 20px;
  padding: 15px;
  background-color: #f9f9f9;
  border-left: 4px solid #003da5;
  border-radius: 4px;
}
.details-actions {
  display: flex;
  gap: 10px;
}
.details-actions button,
.details-actions .nav-btn,
.details-actions .view-document-link { /* Inclure la nouvelle classe de lien */
  padding: 10px 20px;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  font-weight: bold;
  text-decoration: none; /* Pour le lien */
  display: inline-flex; /* Pour le lien, pour centrer le contenu si nécessaire */
  align-items: center;
  justify-content: center;
}
.validate-button { /* Nouveau style pour le bouton de validation */
  background: #28a745;
  color: white;
}
.validate-button:hover {
  background: #218838;
}
.back-btn {
  background: #6c757d;
  color: white;
}
.back-btn:hover {
  background: #5a6268;
}
.view-document-link { /* Nouveau style pour le lien de document */
  background-color: #007bff;
  color: white;
}
.view-document-link:hover {
  background-color: #0056b3;
}
</style>
