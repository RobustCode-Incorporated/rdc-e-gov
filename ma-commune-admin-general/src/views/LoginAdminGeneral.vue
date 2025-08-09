<template>
  <div class="login-container">
    <header class="header-logo">
      <img src="../assets/logo_rdc.png" alt="Logo Gouvernement RDC" class="logo" />
    </header>

    <div class="form-box">
      <h1>Connexion Administrateur Général</h1>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label>Nom d'utilisateur</label>
          <input v-model="credentials.username" required />
        </div>

        <div class="form-group">
          <label>Mot de passe</label>
          <input type="password" v-model="credentials.password" required />
        </div>

        <button type="submit">Se connecter</button>

        <p class="register-link">
          Pas encore de compte ?
          <router-link to="/register">S’enregistrer</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const credentials = ref({
  username: '',
  password: ''
});

const handleLogin = async () => {
  try {
    const res = await axios.post('/api/administrateurs-generaux/login-admin-general', credentials.value);
    localStorage.setItem('token', res.data.token);
    router.push('/admin-general/dashboard');
  } catch (err) {
    alert("Échec de la connexion. Vérifiez vos identifiants.");
  }
};
</script>

<style scoped>
.login-container {
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
  max-width: 480px;
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

input {
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

.register-link {
  margin-top: 16px;
  text-align: center;
  font-size: 14px;
  color: #000;
}

.register-link a {
  color: #0066CC;
  text-decoration: none;
  font-weight: 500;
}
</style>