'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Demande extends Model {
    /**
     * Définition des associations entre modèles
     */
    static associate(models) {
      // Une demande appartient à un citoyen
      Demande.belongsTo(models.Citoyen, {
        foreignKey: 'citoyenId',
        as: 'citoyen',
      });

      // Une demande appartient à une commune
      Demande.belongsTo(models.Commune, {
        foreignKey: 'communeId',
        as: 'commune',
      });

      // Une demande a un statut (Ex : En cours, Validée...)
      Demande.belongsTo(models.Statut, {
        foreignKey: 'statutId',
        as: 'statut',
      });
    }
  }

  Demande.init(
    {
      citoyenId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      communeId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      typeDemande: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      statutId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      donneesJson: {
        type: DataTypes.TEXT,
        allowNull: true, // champs dynamiques
      },
      commentaires: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
    },
    {
      sequelize,
      modelName: 'Demande',
      tableName: 'Demandes', // optionnel
      timestamps: true, // pour garder la date de soumission, modif
    }
  );

  return Demande;
};