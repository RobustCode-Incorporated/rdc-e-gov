'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Administrateur extends Model {
    static associate(models) {
      // Un administrateur appartient à une commune
      Administrateur.belongsTo(models.Commune, {
        foreignKey: 'communeId',
        as: 'commune',
      });

      // Un administrateur peut avoir plusieurs communes assignées (optionnel)
      Administrateur.hasMany(models.Commune, {
        foreignKey: 'adminId',
        as: 'communes',
      });
    }
  }

  Administrateur.init(
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
      nom: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      prenom: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      postnom: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      communeId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
    },
    {
      sequelize,
      modelName: 'Administrateur',
      tableName: 'Administrateurs',
      timestamps: true,
    }
  );

  return Administrateur;
};