// controllers/demandeController.js
const { Demande, Citoyen, Statut, Agent, Commune, Province } = require('../models');
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs').promises;
const { v4: uuidv4 } = require('uuid');
const qrcode = require('qrcode');

const DOCUMENTS_DIR = path.join(__dirname, '..', 'documents');

// Fonction utilitaire pour obtenir l'ID d'un statut par son nom
const getStatutIdByName = async (name) => {
  const statut = await Statut.findOne({ where: { nom: name } });
  return statut ? statut.id : null;
};

module.exports = {
  async getAllDemandes(req, res) {
    try {
      const demandes = await Demande.findAll({
        include: [{ model: Citoyen, as: 'citoyen' }, { model: Statut, as: 'statut' }, { model: Agent, as: 'agent' }],
        order: [['createdAt', 'DESC']]
      });
      res.json(demandes);
    } catch (error) {
      console.error('Erreur getAllDemandes:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async getDemandeById(req, res) {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) return res.status(400).json({ message: "ID invalide" });

      const demande = await Demande.findByPk(id, {
        include: [
          { model: Citoyen, as: 'citoyen' },
          { model: Statut, as: 'statut' },
          { model: Agent, as: 'agent' }
        ]
      });
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      res.json(demande);
    } catch (error) {
      console.error('Erreur getDemandeById:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async createDemande(req, res) {
    try {
      const demande = await Demande.create(req.body);
      res.status(201).json(demande);
    } catch (error) {
      console.error('Erreur createDemande:', error);
      res.status(400).json({ message: 'Erreur création demande', error: error.message });
    }
  },

  async updateDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      await demande.update(req.body);
      res.json(demande);
    } catch (error) {
      console.error('Erreur updateDemande:', error);
      res.status(400).json({ message: 'Erreur mise à jour', error: error.message });
    }
  },

  async deleteDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      await demande.destroy();
      res.status(204).send();
    } catch (error) {
      console.error('Erreur deleteDemande:', error);
      res.status(400).json({ message: 'Erreur suppression', error: error.message });
    }
  },

  async getMyDemandes(req, res) {
    try {
      if (!req.user || req.user.role !== 'citoyen') {
        return res.status(403).json({ message: 'Accès interdit : rôle insuffisant' });
      }

      const demandes = await Demande.findAll({
        where: { citoyenId: req.user.id },
        include: [{ model: Statut, as: 'statut' }],
        order: [['createdAt', 'DESC']]
      });

      res.json(demandes);
    } catch (error) {
      console.error('Erreur getMyDemandes:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async getDemandesToValidate(req, res) {
    try {
      const demandes = await Demande.findAll({
        include: [
          { model: Citoyen, as: 'citoyen' },
          { model: Statut, as: 'statut', where: { nom: 'en_traitement' } },
          { model: Agent, as: 'agent' }
        ],
        order: [['createdAt', 'DESC']]
      });
      res.json(demandes);
    } catch (error) {
      console.error('Erreur getDemandesToValidate:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async generateDocument(req, res) {
    console.log('--- Appel de la fonction generateDocument ---'); // LOG TRÈS IMPORTANT
    try {
      const { id } = req.params;
      console.log(`Tentative de génération de document pour la demande ID: ${id}`);

      const demande = await Demande.findByPk(id, {
        include: [
          {
            model: Citoyen,
            as: 'citoyen',
            include: [{ model: Commune, as: 'commune' }]
          },
          { model: Agent, as: 'agent' },
          { model: Statut, as: 'statut' }
        ]
      });

      if (!demande) {
        console.error(`Erreur: Demande non trouvée pour l'ID: ${id}`);
        return res.status(404).json({ message: "Demande non trouvée." });
      }
      console.log('Demande trouvée:', demande.typeDemande);
      console.log('Statut actuel de la demande:', demande.statut?.nom);
      console.log('Citoyen attaché:', demande.citoyen?.nom, demande.citoyen?.prenom);
      console.log('Commune du citoyen:', demande.citoyen?.commune?.nom);

      await fs.mkdir(DOCUMENTS_DIR, { recursive: true });
      console.log('Dossier documents vérifié/créé.');

      const citoyen = demande.citoyen;
      const donneesDemande = JSON.parse(demande.donneesJson || '{}');
      const typeDemande = demande.typeDemande;

      let htmlContent = '';
      const currentDate = new Date().toLocaleDateString("fr-FR");
      const verificationToken = uuidv4();
      const verificationUrl = `http://localhost:4000/verify-document?token=${verificationToken}`;
      const qrCodeDataURL = await qrcode.toDataURL(verificationUrl);
      console.log('Token et QR Code générés.');

      let communeNaissanceEnfant = null;
      let provinceNaissanceEnfant = null;
      if (donneesDemande.communeNaissanceEnfantId) {
        communeNaissanceEnfant = await Commune.findByPk(donneesDemande.communeNaissanceEnfantId);
        console.log('Commune Naissance Enfant trouvée:', communeNaissanceEnfant?.nom);
      }
      if (donneesDemande.provinceNaissanceEnfantId) {
        provinceNaissanceEnfant = await Province.findByPk(donneesDemande.provinceNaissanceEnfantId);
        console.log('Province Naissance Enfant trouvée:', provinceNaissanceEnfant?.nom);
      }

      console.log('DEBUG: Citoyen Commune:', citoyen.commune?.nom);
      console.log('DEBUG: Donnees Demande:', donneesDemande);
      console.log('DEBUG: Commune Naissance Enfant:', communeNaissanceEnfant?.nom);
      console.log('DEBUG: Province Naissance Enfant:', provinceNaissanceEnfant?.nom);

      switch (typeDemande) {
        case 'acte_naissance':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
              .signature-section { text-align: right; margin-top: 50px; }
              .qr-code { text-align: center; margin-top: 30px; }
              .verification-link { text-align: center; font-size: 0.9em; margin-top: 10px; color: #555; }
            </style>
            <body>
              <div class="header">
                <h3>RÉPUBLIQUE DÉMOCRATIQUE DU CONGO</h3>
                <p>PROVINCE DE KINSHASA</p>
                <p>COMMUNE DE ${citoyen.commune?.nom?.toUpperCase() || 'XXX'}</p>
                <hr>
              </div>
              <h1>ACTE DE NAISSANCE</h1>
              <div class="content">
                <p>Je soussigné, le Bourgmestre de la commune de ${citoyen.commune?.nom || 'XXX'},</p>
                <p>atteste que l'enfant :</p>
                <p><strong>Nom :</strong> ${donneesDemande.nomEnfant || 'N/A'}</p>
                <p><strong>Postnom :</strong> ${donneesDemande.postnomEnfant || 'N/A'}</p>
                <p><strong>Prénom :</strong> ${donneesDemande.prenomEnfant || 'N/A'}</p>
                <p><strong>Sexe :</strong> ${donneesDemande.sexeEnfant || 'N/A'}</p>
                <p><strong>Né(e) le :</strong> ${donneesDemande.dateNaissanceEnfant ? new Date(donneesDemande.dateNaissanceEnfant).toLocaleDateString("fr-FR") : 'N/A'}</p>
                <p><strong>Lieu de naissance :</strong> ${donneesDemande.lieuNaissanceEnfant || 'N/A'}, ${communeNaissanceEnfant?.nom || ''}, ${provinceNaissanceEnfant?.nom || ''}</p>
                <p><strong>Père :</strong> ${donneesDemande.prenomPere || 'N/A'} ${donneesDemande.nomPere || 'N/A'}</p>
                <p><strong>Mère :</strong> ${donneesDemande.prenomMere || 'N/A'} ${donneesDemande.nomMere || 'N/A'}</p>
                <p>Délivré à Kinshasa, le ${currentDate}.</p>
              </div>
              <div class="signature-section">
                <p>Le Bourgmestre</p>
                <p>_________________________</p>
                <p>Signature (Numérique)</p>
              </div>
              <div class="qr-code">
                <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
              </div>
              <p class="verification-link">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
            </body>
          `;
          break;
        case 'acte_mariage':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
              .signature-section { text-align: right; margin-top: 50px; }
              .qr-code { text-align: center; margin-top: 30px; }
              .verification-link { text-align: center; font-size: 0.9em; margin-top: 10px; color: #555; }
            </style>
            <body>
              <div class="header">
                <h3>RÉPUBLIQUE DÉMOCRATIQUE DU CONGO</h3>
                <p>PROVINCE DE KINSHASA</p>
                <p>COMMUNE DE ${citoyen.commune?.nom?.toUpperCase() || 'XXX'}</p>
                <hr>
              </div>
              <h1>ACTE DE MARIAGE</h1>
              <div class="content">
                <p>Le mariage entre :</p>
                <p><strong>Époux :</strong> ${donneesDemande.epouxNom || 'N/A'} ${donneesDemande.epouxPrenom || 'N/A'}</p>
                <p><strong>Épouse :</strong> ${donneesDemande.epouseNom || 'N/A'} ${donneesDemande.epousePrenom || 'N/A'}</p>
                <p>a été célébré le ${donneesDemande.dateMariage ? new Date(donneesDemande.dateMariage).toLocaleDateString("fr-FR") : 'N/A'} dans notre commune.</p>
                <p>Délivré à Kinshasa, le ${currentDate}.</p>
              </div>
              <div class="signature-section">
                <p>Le Bourgmestre</p>
                <p>_________________________</p>
                <p>Signature (Numérique)</p>
              </div>
              <div class="qr-code">
                <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
              </div>
              <p class="verification-link">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
            </body>
          `;
          break;
        case 'acte_residence':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
              .signature-section { text-align: right; margin-top: 50px; }
              .qr-code { text-align: center; margin-top: 30px; }
              .verification-link { text-align: center; font-size: 0.9em; margin-top: 10px; color: #555; }
            </style>
            <body>
              <div class="header">
                <h3>RÉPUBLIQUE DÉMOCRATIQUE DU CONGO</h3>
                <p>PROVINCE DE KINSHASA</p>
                <p>COMMUNE DE ${citoyen.commune?.nom?.toUpperCase() || 'XXX'}</p>
                <hr>
              </div>
              <h1>CERTIFICAT DE RÉSIDENCE</h1>
              <div class="content">
                <p>Je soussigné, le Bourgmestre de la commune de ${citoyen.commune?.nom || 'XXX'},</p>
                <p>atteste que le citoyen :</p>
                <p><strong>Nom :</strong> ${citoyen.nom || 'N/A'}</p>
                <p><strong>Postnom :</strong> ${citoyen.postnom || 'N/A'}</p>
                <p><strong>Prénom :</strong> ${citoyen.prenom || 'N/A'}</p>
                <p><strong>Réside à :</strong> ${donneesDemande.adresseResidence || 'N/A'}, ${citoyen.commune?.nom || 'XXX'}, Kinshasa.</p>
                <p>Délivré à Kinshasa, le ${currentDate}.</p>
              </div>
              <div class="signature-section">
                <p>Le Bourgmestre</p>
                <p>_________________________</p>
                <p>Signature (Numérique)</p>
              </div>
              <div class="qr-code">
                <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
              </div>
              <p class="verification-link">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
            </body>
          `;
          break;
        case 'carte_identite':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
              .signature-section { text-align: right; margin-top: 50px; }
              .qr-code { text-align: center; margin-top: 30px; }
              .verification-link { text-align: center; font-size: 0.9em; margin-top: 10px; color: #555; }
              .card-layout { display: flex; border: 1px solid #ccc; padding: 20px; border-radius: 10px; max-width: 400px; margin: 20px auto; box-shadow: 2px 2px 8px rgba(0,0,0,0.1); }
              .card-left { flex: 1; text-align: center; padding-right: 20px; }
              .card-right { flex: 2; }
              .profile-pic { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 2px solid #003da5; }
              .card-info p { margin: 5px 0; }
            </style>
            <body>
              <div class="header">
                <h3>RÉPUBLIQUE DÉMOCRATIQUE DU CONGO</h3>
                <p>PROVINCE DE KINSHASA</p>
                <p>COMMUNE DE ${citoyen.commune?.nom?.toUpperCase() || 'XXX'}</p>
                <hr>
              </div>
              <h1>CARTE D'IDENTITÉ NATIONALE</h1>
              <div class="card-layout">
                <div class="card-left">
                  <img src="https://placehold.co/100x100/003DA5/FFFFFF?text=PHOTO" alt="Photo de profil" class="profile-pic">
                  <div class="qr-code">
                    <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="80" height="80">
                  </div>
                </div>
                <div class="card-right card-info">
                  <p><strong>Nom :</strong> ${citoyen.nom || 'N/A'}</p>
                  <p><strong>Postnom :</strong> ${citoyen.postnom || 'N/A'}</p>
                  <p><strong>Prénom :</strong> ${citoyen.prenom || 'N/A'}</p>
                  <p><strong>Né(e) le :</strong> ${citoyen.dateNaissance ? new Date(citoyen.dateNaissance).toLocaleDateString("fr-FR") : 'N/A'}</p>
                  <p><strong>Sexe :</strong> ${citoyen.sexe || 'N/A'}</p>
                  <p><strong>Lieu de Naissance :</strong> ${citoyen.lieuNaissance || 'N/A'}</p>
                  <p><strong>N° Unique :</strong> ${citoyen.numeroUnique || 'N/A'}</p>
                  <p><strong>Délivrée le :</strong> ${currentDate}</p>
                </div>
              </div>
              <p class="verification-link" style="text-align: center; margin-top: 20px;">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
              <div class="signature-section" style="text-align: right; margin-top: 30px;">
                <p>Le Bourgmestre</p>
                <p>_________________________</p>
                <p>Signature (Numérique)</p>
              </div>
            </body>
          `;
          break;
        default:
          htmlContent = `
            <body>
              <h1>Document Non Standard</h1>
              <p>Type de document non reconnu ou template non disponible.</p>
              <p>ID Demande: ${demande.id}</p>
              <p>Type: ${demande.typeDemande}</p>
              <p>Délivré à Kinshasa, le ${currentDate}.</p>
              <div class="qr-code">
                <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
              </div>
              <p class="verification-link">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
            </body>
          `;
      }

      console.log('HTML Content ready. Launching Puppeteer...');
      const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
      const page = await browser.newPage();
      await page.setContent(htmlContent);
      console.log('Page content set.');

      const filename = `${typeDemande}_${demande.id}_${verificationToken}.pdf`;
      const pdfPath = path.join(DOCUMENTS_DIR, filename);

      await fs.mkdir(DOCUMENTS_DIR, { recursive: true }).catch(err => {
        console.error("Erreur lors de la création du dossier 'documents':", err);
        // Si la création du dossier échoue, on peut choisir d'arrêter ici ou de continuer si le dossier existe déjà
        // Pour l'instant, on continue, mais l'erreur est loggée.
      });
      console.log(`Tentative de génération du PDF vers: ${pdfPath}`);
      await page.pdf({ path: pdfPath, format: 'A4', printBackground: true });
      console.log('PDF généré avec succès.');

      await browser.close();
      console.log('Navigateur Puppeteer fermé.');

      await demande.update({
        documentPath: filename,
        verificationToken: verificationToken
      });
      console.log('Demande mise à jour en base de données avec documentPath et verificationToken.');

      res.json({
        message: "Document généré avec succès pour la validation.",
        documentUrl: `${filename}`,
        verificationUrl: verificationUrl
      });
      console.log('--- Fin de la fonction generateDocument (Succès) ---');

    } catch (error) {
      console.error("--- Erreur CRITIQUE de génération de document ---");
      console.error("Détails de l'erreur:", error);
      if (error.stack) {
        console.error("Stack Trace:", error.stack);
      }
      res.status(500).json({ message: "Erreur serveur lors de la génération du document.", error: error.message });
      console.log('--- Fin de la fonction generateDocument (Échec) ---');
    }
  },

  async validateDocument(req, res) {
    try {
      const { id } = req.params;
      const demande = await Demande.findByPk(id, { include: [{ model: Statut, as: 'statut' }] });

      if (!demande) {
        return res.status(404).json({ message: "Demande non trouvée." });
      }

      if (demande.statut.nom !== 'en_traitement') {
        return res.status(400).json({ message: "La demande ne peut pas être validée si elle n'est pas 'en_traitement'." });
      }

      const valideeStatutId = await getStatutIdByName('validee');
      if (!valideeStatutId) {
        return res.status(500).json({ message: "Statut 'validee' non trouvé." });
      }

      await demande.update({ statutId: valideeStatutId });

      res.json({ message: "Demande validée avec succès !" });

    } catch (error) {
      console.error('Erreur validateDocument:', error);
      res.status(500).json({ message: "Erreur lors de la validation de la demande.", error: error.message });
    }
  },

  async getAllStatuts(req, res) {
    try {
      const statuts = await Statut.findAll();
      return res.status(200).json(statuts);
    } catch (error) {
      console.error('Erreur getAllStatuts:', error);
      return res.status(500).json({ message: 'Erreur serveur lors de la récupération des statuts', error: error.message });
    }
  }
};
