<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: "App",
  mounted() {
    // Optionnel : redirige si pas de token stocké
    const token = localStorage.getItem("token");
    if (!token && this.$route.path !== "/login") {
      this.$router.push("/login");
    }
  }
};
</script>

<style>
/* Styles globaux */
body {
  margin: 0;
  font-family: "Inter", sans-serif;
  background-color: #f5f6fa;
}
#app {
  min-height: 100vh;
}
</style>