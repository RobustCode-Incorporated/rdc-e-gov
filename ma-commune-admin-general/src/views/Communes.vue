<template>
  <div class="page-communes">
    <header class="header-logo">
      <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
    </header>

    <h2>📍 Communes de votre province</h2>

    <section v-if="loading">Chargement...</section>

    <section v-else>
      <table>
        <thead>
          <tr>
            <th>Nom</th>
            <th>Code</th>
            <th>Bourgmestre</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="commune in communes" :key="commune.id">
            <td>{{ commune.nom }}</td>
            <td>{{ commune.code || "-" }}</td>
            <td>
              <template v-if="commune.administrateur">
                ✅ {{ formatNomComplet(commune.administrateur) }}
              </template>
              <template v-else>
                ❌ Non assigné
              </template>
            </td>
            <td>
              <template v-if="commune.administrateur">
                <button @click="removeBourgmestre(commune)">Supprimer le bourgmestre</button>
              </template>
              <template v-else>
                <button @click="goToAssignBourgmestre">Assigner un bourgmestre</button>
              </template>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: "Communes",
  data() {
    return {
      loading: true,
      communes: []
    };
  },
  methods: {
    formatNomComplet(admin) {
      return [admin.nom, admin.prenom, admin.postnom].filter(Boolean).join(' ');
    },

    async fetchCommunes() {
      this.loading = true;
      try {
        const token = localStorage.getItem('token');
        const payload = this.decodeToken(token);
        if (!payload?.provinceId) {
          console.error("provinceId manquant dans token");
          this.loading = false;
          return;
        }
        const url = `http://localhost:4000/api/communes/province/${payload.provinceId}`;
        const res = await axios.get(url, {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.communes = res.data;
      } catch (error) {
        console.error("Erreur chargement communes:", error);
      } finally {
        this.loading = false;
      }
    },

    decodeToken(token) {
      if (!token) return null;
      try {
        const payloadBase64 = token.split('.')[1];
        return JSON.parse(atob(payloadBase64));
      } catch {
        return null;
      }
    },

    goToAssignBourgmestre() {
      this.$router.push('/administrateurs'); // Page d'ajout/gestion bourgmestre
    },

    async removeBourgmestre(commune) {
      if (!confirm(`Voulez-vous vraiment supprimer le bourgmestre de ${commune.nom} ?`)) return;
      try {
        const token = localStorage.getItem('token');
        await axios.put(
          `http://localhost:4000/api/communes/${commune.id}/assign-admin`,
          { adminId: null },
          { headers: { Authorization: `Bearer ${token}` } }
        );
        await this.fetchCommunes();
      } catch (error) {
        console.error("Erreur suppression bourgmestre :", error);
        alert("Erreur lors de la suppression du bourgmestre.");
      }
    }
  },
  async mounted() {
    await this.fetchCommunes();
  }
};
</script>

<style scoped>
.page-communes {
  padding: 30px;
  font-family: "Inter", sans-serif;
}
.header-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}
.logo {
  max-height: 60px;
  object-fit: contain;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}
th,
td {
  border: 1px solid #ddd;
  padding: 12px;
}
th {
  background-color: #003da5;
  color: white;
}
button {
  background: #003da5;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
}
button:hover {
  background: #00276f;
}
</style>