<template>
    <div class="login-page">
      <div class="login-card">
        <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
        <h2>Connexion Bourgmestre</h2>
  
        <form @submit.prevent="handleLogin">
          <div class="form-group">
            <label>Nom d'utilisateur</label>
            <input v-model="username" type="text" placeholder="Entrez votre nom d'utilisateur" required />
          </div>
  
          <div class="form-group">
            <label>Mot de passe</label>
            <input v-model="password" type="password" placeholder="Entrez votre mot de passe" required />
          </div>
  
          <button type="submit" :disabled="loading">
            {{ loading ? "Connexion..." : "Se connecter" }}
          </button>
  
          <p v-if="error" class="error">{{ error }}</p>
        </form>
      </div>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    name: "LoginBourgmestre",
    data() {
      return {
        username: "",
        password: "",
        loading: false,
        error: null,
      };
    },
    methods: {
      async handleLogin() {
        this.loading = true;
        this.error = null;
        try {
          const res = await axios.post('http://localhost:4000/api/administrateurs/login', {
            username: this.username,
            password: this.password,
          });
  
          // Sauvegarder le token
          localStorage.setItem("token", res.data.token);
  
          // Rediriger vers le dashboard
          this.$router.push("/dashboard-bourgmestre");
        } catch (err) {
          console.error("Erreur connexion bourgmestre :", err);
          this.error = err.response?.data?.message || "Connexion échouée";
        } finally {
          this.loading = false;
        }
      },
    },
  };
  </script>
  
  <style scoped>
  .login-page {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: #f7f7f7;
    font-family: "Roboto", sans-serif;
  }
  .login-card {
    background: white;
    padding: 30px;
    border-radius: 8px;
    width: 350px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    text-align: center;
  }
  .logo {
    height: 60px;
    margin-bottom: 20px;
  }
  h2 {
    margin-bottom: 20px;
    color: #003da5;
  }
  .form-group {
    margin-bottom: 15px;
    text-align: left;
  }
  label {
    font-weight: bold;
    font-size: 14px;
  }
  input {
    width: 100%;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
  }
  button {
    width: 100%;
    padding: 10px;
    background: #003da5;
    color: white;
    font-weight: bold;
    border: none;
    border-radius: 6px;
    cursor: pointer;
  }
  button:disabled {
    background: gray;
  }
  button:hover:not(:disabled) {
    background: #00276f;
  }
  .error {
    color: red;
    margin-top: 10px;
  }
  </style>