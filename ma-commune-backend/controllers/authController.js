const { Administrateur, Agent, Citoyen } = require('../models');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  const { username, password, role } = req.body;

  try {
    let user, userRole;

    switch (role) {
      case 'admin':
        user = await Administrateur.findOne({ where: { username } });
        userRole = 'admin';
        break;
      case 'agent':
        user = await Agent.findOne({ where: { username } });
        userRole = 'agent';
        break;
      case 'citoyen':
        user = await Citoyen.findOne({ where: { numeroUnique: username } });
        userRole = 'citoyen';
        break;
      default:
        return res.status(400).json({ message: 'Rôle invalide' });
    }

    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Identifiants incorrects' });
    }

    const token = jwt.sign(
      { id: user.id, role: userRole, communeId: user.communeId },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({ token });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};