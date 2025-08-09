'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Agent extends Model {
    /**
     * Définir les associations
     */
    static associate(models) {
      // Un agent appartient à une commune
      Agent.belongsTo(models.Commune, {
        foreignKey: 'communeId',
        as: 'commune',
      });

      // Si plus tard on veut lier les agents aux demandes qu’ils traitent,
      // on pourrait ajouter une association ici (non nécessaire pour le moment)
    }
  }

  Agent.init(
    {
      username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
      },
      password: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      communeId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      typeDemande: {
        type: DataTypes.STRING,
        allowNull: false,
        comment: 'Type de demande que l’agent peut traiter (ex: acte naissance)',
      },
    },
    {
      sequelize,
      modelName: 'Agent',
      tableName: 'Agents',
      timestamps: true,
    }
  );

  return Agent;
};