<template>
  <div class="page-communes">
    <h2>📍 Communes de votre province</h2>

    <section v-if="loading">Chargement...</section>

    <section v-else>
      <table>
        <thead>
          <tr>
            <th>Nom</th>
            <th>Code</th>
            <th>Administrateur</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="commune in communes" :key="commune.id">
            <td>{{ commune.nom }}</td>
            <td>{{ commune.code || '-' }}</td>
            <td>
              <div class="admin-status">
                <template v-if="commune.administrateur">
                  <span class="status-assigned">
                    ✅ {{ commune.administrateur.nomComplet || commune.administrateur.username }}
                  </span>
                </template>
                <template v-else>
                  <span class="status-unassigned">❌ Non assigné</span>
                </template>
              </div>
            </td>
            <td>
              <button @click="openAssignModal(commune)">Assigner / Modifier</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- Modal pour assigner un admin -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Assigner un administrateur</h3>
        <label for="adminSelect">Choisir un administrateur :</label>
        <select v-model="selectedAdminId" id="adminSelect">
          <option :value="null">-- Aucun --</option>
          <option v-for="admin in admins" :value="admin.id" :key="admin.id">
            {{ admin.nomComplet || admin.username }}
          </option>
        </select>

        <div class="modal-actions">
          <button @click="assignAdmin">Valider</button>
          <button @click="closeModal">Annuler</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'Communes',
  data() {
    return {
      loading: true,
      communes: [],
      admins: [],
      showModal: false,
      selectedCommune: null,
      selectedAdminId: null,
    };
  },
  methods: {
    getTokenPayload() {
      const token = localStorage.getItem('token');
      if (!token) return null;
      try {
        const payloadBase64 = token.split('.')[1];
        const payloadJson = atob(payloadBase64);
        return JSON.parse(payloadJson);
      } catch (e) {
        console.error('Erreur décodage token:', e);
        return null;
      }
    },

    async fetchCommunes() {
      try {
        const token = localStorage.getItem('token');
        const payload = this.getTokenPayload();
        if (!payload?.provinceId) {
          console.error('provinceId non trouvé dans le token');
          return;
        }
        const url = `http://localhost:4000/api/communes/province/${payload.provinceId}`;
        console.log('Fetching communes from:', url);

        const response = await axios.get(url, {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.communes = response.data;
      } catch (error) {
        if (error.response) {
          console.error('Erreur API:', error.response.status, error.response.data);
        } else if (error.request) {
          console.error('Aucune réponse reçue:', error.request);
        } else {
          console.error('Erreur:', error.message);
        }
      }
    },

    async fetchAdmins() {
      try {
        const token = localStorage.getItem('token');
        const payload = this.getTokenPayload();
        if (!payload) {
          console.error('Token invalide');
          return;
        }

        // Seul admin_general peut appeler cette route
        if (payload.role !== 'admin_general') {
          console.log('Utilisateur non admin_general, pas de fetch admins');
          this.admins = [];
          return;
        }

        const url = `http://localhost:4000/api/administrateurs/province`;
        console.log('Fetching admins from:', url);

        const response = await axios.get(url, {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.admins = response.data;
      } catch (error) {
        if (error.response) {
          console.error('Erreur API:', error.response.status, error.response.data);
        } else if (error.request) {
          console.error('Aucune réponse reçue:', error.request);
        } else {
          console.error('Erreur:', error.message);
        }
      }
    },

    openAssignModal(commune) {
      this.selectedCommune = commune;
      this.selectedAdminId = commune.administrateur ? commune.administrateur.id : null;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.selectedCommune = null;
      this.selectedAdminId = null;
    },

    async assignAdmin() {
      if (!this.selectedCommune) return;

      try {
        const token = localStorage.getItem('token');
        await axios.put(
          `http://localhost:4000/api/communes/${this.selectedCommune.id}/assign-admin`,
          { adminId: this.selectedAdminId },
          { headers: { Authorization: `Bearer ${token}` } }
        );

        await this.fetchCommunes();
        this.closeModal();
      } catch (error) {
        console.error('Erreur assignation admin:', error);
      }
    }
  },

  async mounted() {
    try {
      await this.fetchCommunes();
      await this.fetchAdmins();
    } catch (e) {
      console.error('Erreur chargement initial:', e);
    } finally {
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.page-communes {
  padding: 30px;
  font-family: 'Inter', sans-serif;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}
th, td {
  border: 1px solid #ddd;
  padding: 12px;
}
th {
  background-color: #003DA5;
  color: white;
}
.not-assigned {
  color: red;
  font-style: italic;
}
button {
  background: #003DA5;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
}
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  justify-content: center;
  align-items: center;
}
.modal-content {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 400px;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

/* Ajout indicateurs visuels */
.admin-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-assigned {
  color: green;
  font-weight: bold;
}

.status-unassigned {
  color: red;
  font-weight: bold;
  font-style: italic;
}
</style>