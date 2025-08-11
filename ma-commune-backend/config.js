// config.js
require('dotenv').config();

const jwtSecret = process.env.JWT_SECRET || 'ma_cle_super_secrete';

console.log('Clé JWT utilisée:', jwtSecret); // juste pour debug au démarrage

module.exports = {
  jwtSecret,
};