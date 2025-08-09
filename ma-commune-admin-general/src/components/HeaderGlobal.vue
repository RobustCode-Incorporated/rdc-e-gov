<template>
    <header class="header-global">
      <img src="../assets/logo_rdc.png" alt="Logo RDC" class="logo" />
      <nav class="nav-menu">
        <ul>
          <li><router-link to="/admin-general/dashboard">Dashboard</router-link></li>
          <li><router-link to="/admin-genral/profile">Profil</router-link></li>
          <li><button @click="logout" class="btn-logout">Déconnexion</button></li>
        </ul>
      </nav>
    </header>
  </template>
  
  <script setup>
  import { useAuthStore } from '../store';
  
  const auth = useAuthStore();
  
  function logout() {
    auth.logout();
  }
  </script>
  
  <style scoped>
  .header-global {
    display: flex;
    align-items: center;
    padding: 16px 32px;
    background-color: #003DA5; /* Bleu gouvernemental */
    color: white;
    box-shadow: 0 2px 4px rgb(0 0 0 / 0.1);
  }
  
  .logo {
    height: 50px; /* Respect taille charte */
    margin-right: 32px;
  }
  
  .nav-menu ul {
    list-style: none;
    display: flex;
    gap: 24px;
    margin: 0;
    padding: 0;
  }
  
  .nav-menu a {
    color: white;
    font-family: 'Roboto', 'Montserrat', sans-serif;
    font-weight: 500;
    font-size: 16px;
    text-decoration: none;
    transition: color 0.3s;
  }
  
  .nav-menu a:hover {
    color: #FFD100; /* Jaune accent */
  }
  
  .btn-logout {
    background: transparent;
    border: 1px solid white;
    border-radius: 6px;
    color: white;
    font-family: 'Roboto', sans-serif;
    font-weight: 500;
    padding: 6px 12px;
    cursor: pointer;
    transition: background-color 0.3s, color 0.3s;
  }
  
  .btn-logout:hover {
    background-color: #FFD100;
    color: #003DA5;
  }
  </style>