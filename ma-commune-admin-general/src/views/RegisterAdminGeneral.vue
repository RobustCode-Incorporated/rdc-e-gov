<template>
  <div class="register-container">
    <header class="header-logo">
      <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
    </header>

    <div class="form-box">
      <h1>Créer un compte Administrateur Général</h1>
      <form @submit.prevent="handleRegister">
        <div class="form-group">
          <label>Nom</label>
          <input v-model="form.nom" required />
        </div>

        <div class="form-group">
          <label>Prénom</label>
          <input v-model="form.prenom" required />
        </div>

        <div class="form-group">
          <label>Postnom (optionnel)</label>
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
          <label>Province</label>
          <select v-model="form.provinceId" required>
            <option value="" disabled>-- Sélectionnez une province --</option>
            <option v-for="province in provinces" :key="province.id" :value="province.id">
              {{ province.nom }}
            </option>
          </select>
        </div>

        <button type="submit">Créer le compte</button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const form = ref({
  nom: '',
  prenom: '',
  postnom: '',
  username: '',
  email: '',
  password: '',
  provinceId: '',
  role: 'admin_general'
});

const provinces = ref([]);

const handleRegister = async () => {
  try {
    await axios.post('/api/administrateurs-generaux', form.value);
    alert('Compte créé avec succès ! Vous pouvez maintenant vous connecter.');
    window.location.href = '/';
  } catch (error) {
    console.error('Erreur lors de l’enregistrement :', error);
    alert("Erreur lors de la création du compte.");
  }
};

onMounted(async () => {
  try {
    const res = await axios.get('http://localhost:4000/api/provinces');
    console.log('Provinces API response:', res.data);
    provinces.value = res.data;
  } catch (error) {
    console.error('Erreur lors du chargement des provinces :', error);
  }
});
</script>

<style scoped>
.register-container {
  background-color: #F7F7F7;
  min-height: 100vh;
  padding: 40px;
}

.header-logo {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  padding-bottom: 16px;
}

.logo {
  height: 60px;
  margin-left: 8px;
}

.form-box {
  max-width: 500px;
  margin: 40px auto;
  background-color: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 0 8px rgba(0, 61, 165, 0.2);
}

h1 {
  font-family: 'Roboto', sans-serif;
  color: #003DA5;
  margin-bottom: 24px;
  font-size: 24px;
}

.form-group {
  margin-bottom: 20px;
}

label {
  display: block;
  font-weight: 500;
  margin-bottom: 6px;
  font-family: 'Roboto', sans-serif;
}

input, select {
  width: 100%;
  padding: 10px;
  border: 1px solid #CCC;
  border-radius: 6px;
  font-family: 'Open Sans', sans-serif;
}

button {
  background-color: #003DA5;
  color: white;
  padding: 12px 24px;
  border: none;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #00276f;
}
</style>