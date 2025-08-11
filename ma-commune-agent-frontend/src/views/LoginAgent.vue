<template>
    <div class="login-page">
      <div class="login-container">
        <!-- Logo -->
        <div class="logo-container">
          <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
          <h1 class="title">PORTAIL AGENT</h1>
        </div>
  
        <!-- Formulaire -->
        <form @submit.prevent="login" class="login-form">
          <div class="form-group">
            <label for="username">Nom d'utilisateur</label>
            <input
              type="text"
              id="username"
              v-model="username"
              placeholder="Entrez votre nom d'utilisateur"
              required
            />
          </div>
  
          <div class="form-group">
            <label for="password">Mot de passe</label>
            <input
              type="password"
              id="password"
              v-model="password"
              placeholder="Entrez votre mot de passe"
              required
            />
          </div>
  
          <button type="submit" class="login-btn">
            Connexion
          </button>
  
          <p v-if="error" class="error">{{ error }}</p>
        </form>
      </div>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    name: "LoginAgent",
    data() {
      return {
        username: "",
        password: "",
        error: "",
      };
    },
    methods: {
      async login() {
        try {
          const res = await axios.post("http://localhost:4000/api/agents/login", {
            username: this.username,
            password: this.password,
          });
  
          // Sauvegarde du token
          localStorage.setItem("token", res.data.token);
  
          // Redirection vers dashboard
          this.$router.push("/dashboard");
        } catch (err) {
          this.error = err.response?.data?.message || "Erreur de connexion";
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
    background: #f3f4f6;
  }
  
  .login-container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    width: 400px;
    box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.1);
  }
  
  .logo-container {
    text-align: center;
    margin-bottom: 20px;
  }
  
  .logo {
    height: 70px;
  }
  
  .title {
    font-family: "Ysabeau Office", sans-serif;
    font-size: 20px;
    margin-top: 10px;
    color: #0e2c5a;
  }
  
  .login-form {
    display: flex;
    flex-direction: column;
  }
  
  .form-group {
    margin-bottom: 15px;
  }
  
  label {
    font-weight: bold;
    font-family: "ABeeZee", sans-serif;
    color: #0e2c5a;
  }
  
  input {
    padding: 10px;
    width: 100%;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-family: "ABeeZee", sans-serif;
  }
  
  .login-btn {
    background-color: #104b71;
    color: white;
    border: none;
    padding: 12px;
    border-radius: 6px;
    cursor: pointer;
    font-family: "Inter", sans-serif;
    font-weight: bold;
    margin-top: 10px;
  }
  
  .login-btn:hover {
    background-color: #0e2c5a;
  }
  
  .error {
    margin-top: 10px;
    color: red;
    font-size: 14px;
  }
  </style>