<template>
  <div class="page-communes">
    <!-- Navbar -->
    <header class="navbar">
      <div class="navbar-left">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h1>Gestions des Communes</h1>
      </div>
      <div class="navbar-right">
        <router-link to="/admin-general/dashboard" class="nav-btn">Accueil</router-link>
        <router-link to="/administrateurs" class="nav-btn">Bourgmestres</router-link>
        <button @click="logout" class="logout-btn">Déconnexion</button>
      </div>
    </header>

    <!-- Contenu -->
    <main class="content">
      <h2>📍 Communes de votre province</h2>

      <section v-if="loading" class="loading">Chargement...</section>

      <section v-else>
        <table class="communes-table">
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
                  <button @click="removeBourgmestre(commune)" class="action-btn remove-btn">
                    Supprimer le bourgmestre
                  </button>
                </template>
                <template v-else>
                  <button @click="goToAssignBourgmestre" class="action-btn assign-btn">
                    Assigner un bourgmestre
                  </button>
                </template>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </main>
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
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/");
    },
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
      this.$router.push('/administrateurs');
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
.navbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.logo {
  height: 42px;
}
.navbar-right {
  display: flex;
  gap: 14px;
}
.nav-btn {
  background: white;
  color: #003da5;
  padding: 8px 16px;
  border-radius: 6px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
}
.nav-btn:hover {
  background: #f1f1f1;
  transform: translateY(-2px);
}
.logout-btn {
  background: #db3832;
  color: white;
  padding: 8px 16px;
  border-radius: 6px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}
.logout-btn:hover {
  background: #b52b26;
  transform: translateY(-2px);
}

/* --- CONTENU --- */
.content {
  padding: 32px;
  font-family: "Inter", sans-serif;
  background: #f7f7f7;
  min-height: calc(100vh - 70px);
}

/* --- TABLEAU COMMUNES --- */
.communes-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0 10px;
  margin-top: 20px;
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.communes-table th,
.communes-table td {
  padding: 14px 16px;
  text-align: left;
}
.communes-table thead {
  background: #003da5;
  color: white;
  font-weight: 600;
}
.communes-table tbody tr {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.communes-table tbody tr:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.action-btn {
  padding: 8px 14px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.assign-btn {
  background: #104b71;
  color: white;
}
.assign-btn:hover {
  background: #0e2c5a;
}
.remove-btn {
  background: #db3832;
  color: white;
}
.remove-btn:hover {
  background: #b52b26;
}
.loading {
  font-size: 18px;
  color: #003da5;
}
</style>