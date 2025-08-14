<template>
    <div class="page-validation-admin">
      <h2>Demandes en attente de validation</h2>
  
      <table>
        <thead>
          <tr>
            <th>Type</th>
            <th>Citoyen</th>
            <th>Agent Traitant</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="demande in demandes" :key="demande.id">
            <td>{{ getTypeDemandeLabel(demande.typeDemande) }}</td>
            <td>{{ formatNomComplet(demande.citoyen) }}</td>
            <td>{{ formatNomComplet(demande.agent) }}</td>
            <td>{{ formatDate(demande.createdAt) }}</td>
            <td>
              <button @click="openModal(demande)">Valider</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script>
  // ... (logique fetchDemandes, formatage, etc., mais en appelant /api/demandes/validation)
  import axios from "axios";
  
  export default {
    // ... (data, methods pour le formatage, etc.)
    methods: {
      async fetchDemandesToValidate() {
        // Logic to fetch from the new endpoint
      },
      openModal(demande) {
        // Logic for the modal
      }
    },
    mounted() {
      this.fetchDemandesToValidate();
    }
  }
  </script>

  