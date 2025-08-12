<template>
  <div class="container">
    <header class="header-logo">
      <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
    </header>

    <header class="page-header">
      <h1>Gestion des Administrateurs</h1>
    </header>

    <section v-if="loading">Chargement des administrateurs...</section>

    <section v-else class="grid">
      <div v-for="admin in administrateurs" :key="admin.id" class="card">
        <h2>{{ admin.nomComplet }}</h2>
        <p><strong>Username :</strong> {{ admin.username }}</p>
        <p><strong>Email :</strong> {{ admin.email || 'N/A' }}</p>
        <p><strong>Commune :</strong> {{ admin.communes.length ? admin.communes[0].nom : 'N/A' }}</p>
        <p><strong>Rôle :</strong> {{ admin.role || 'Bourgmestre' }}</p>
      </div>
    </section>

    <section class="form-section">
      <h2>Ajouter un nouveau Bourgmestre</h2>
      <form @submit.prevent="handleAddAdmin">
        <div class="form-group">
          <label>Nom</label>
          <input v-model="form.nom" required />
        </div>
        <div class="form-group">
          <label>Prénom</label>
          <input v-model="form.prenom" />
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
          <label>Email</label>
          <input type="email" v-model="form.email" />
        </div>
        <div class="form-group">
          <label>Mot de passe</label>
          <input type="password" v-model="form.password" required />
        </div>
        <div class="form-group">
          <label>Commune</label>
          <select v-model="form.communeId" required>
            <option value="" disabled>-- Choisir une commune --</option>
            <option v-for="commune in communes" :key="commune.id" :value="commune.id">
              {{ commune.nom }}
            </option>
          </select>
        </div>
        <button type="submit">Ajouter</button>
      </form>
    </section>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'Administrateurs',
  data() {
    return {
      administrateurs: [],
      communes: [],
      loading: true,
      form: {
        nom: '',
        prenom: '',
        postnom: '',
        username: '',
        email: '',
        password: '',
        communeId: '',
      },
    };
  },
  async mounted() {
    await Promise.all([this.fetchAdministrateurs(), this.fetchCommunes()]);
  },
  methods: {
    async fetchAdministrateurs() {
      this.loading = true;
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get('http://localhost:4000/api/administrateurs', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.administrateurs = res.data;
      } catch (error) {
        console.error('Erreur lors du chargement des administrateurs :', error);
      } finally {
        this.loading = false;
      }
    },
    async fetchCommunes() {
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get('http://localhost:4000/api/communes/province/1', {
          headers: { Authorization: `Bearer ${token}` },
        });
        // Correction : assigner les données de l'API à la variable communes du composant
        this.communes = res.data; 
      } catch (error) {
        console.error('Erreur lors du chargement des communes :', error);
      }
    },
    async handleAddAdmin() {
      try {
        const token = localStorage.getItem('token');
        await axios.post('http://localhost:4000/api/administrateurs', this.form, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert('Bourgmestre ajouté avec succès !');
        this.form = {
          nom: '',
          prenom: '',
          postnom: '',
          username: '',
          email: '',
          password: '',
          communeId: '',
        };
        await this.fetchAdministrateurs();
      } catch (error) {
        console.error('Erreur ajout bourgmestre:', error);
        alert('Erreur lors de l\'ajout du bourgmestre.');
      }
    }
  }
};
</script>

<style scoped>
.container {
  padding: 32px;
  background: #f7f7f7;
  font-family: 'Roboto', sans-serif;
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
.page-header {
  margin-bottom: 24px;
}
.grid {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-bottom: 40px;
}
.card {
  background: white;
  border-radius: 6px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.1);
  width: 300px;
}
.card h2 {
  margin-bottom: 8px;
  color: #003DA5;
}
.form-section {
  background: white;
  padding: 20px;
  border-radius: 6px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.1);
  max-width: 600px;
}
.form-group {
  margin-bottom: 16px;
}
label {
  display: block;
  font-weight: 600;
  margin-bottom: 6px;
}
input, select {
  width: 100%;
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #ccc;
  font-size: 14px;
}
button {
  background: #003DA5;
  color: white;
  padding: 10px 24px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}
button:hover {
  background: #00276f;
}
</style>