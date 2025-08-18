// controllers/demandeController.js
const { Demande, Citoyen, Statut, Agent, Commune, Province, Administrateur } = require('../models'); // Added Administrateur model
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
      // Inclut toutes les associations nécessaires pour afficher les détails complets
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

      // Define the base signature block without the Bourgmestre's name/font for initial generation
      const baseSignatureBlock = `
        <div class="signature-section" style="text-align: right; margin-top: 50px;">
          <p>Le Bourgmestre</p>
          <p>_________________________</p>
          <p>Signature (Numérique)</p>
        </div>
        <div class="qr-code" style="text-align: center; margin-top: 30px;">
          <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
        </div>
        <p class="verification-link" style="text-align: center; font-size: 0.9em; margin-top: 10px; color: #555;">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
      `;

      switch (typeDemande) {
        case 'acte_naissance':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
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
              ${baseSignatureBlock}
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
              ${baseSignatureBlock}
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
              ${baseSignatureBlock}
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
              ${baseSignatureBlock}
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
      // En cas d'échec de la génération, mettez explicitement documentPath à null
      await demande.update({
        documentPath: null,
        verificationToken: null // Ou conservez le token si vous voulez retracer la tentative
      }).catch(dbErr => {
        console.error("Erreur lors de la mise à jour de la demande après échec de génération:", dbErr);
      });
      res.status(500).json({ message: "Erreur serveur lors de la génération du document.", error: error.message });
      console.log('--- Fin de la fonction generateDocument (Échec) ---');
    }
  },

  async validateDocument(req, res) {
    console.log('--- Appel de la fonction validateDocument (Signature) ---');
    try {
      const { id } = req.params;
      // Fetch all necessary associations to reconstruct the HTML
      const demande = await Demande.findByPk(id, {
        include: [
          {
            model: Citoyen,
            as: 'citoyen',
            include: [{ model: Commune, as: 'commune' }]
          },
          { model: Agent, as: 'agent' }, // Make sure the agent data is loaded
          { model: Statut, as: 'statut' }
        ]
      });
  
      if (!demande) {
        console.error(`Erreur: Demande non trouvée pour l'ID: ${id}`);
        return res.status(404).json({ message: "Demande non trouvée." });
      }
  
      if (demande.statut.nom !== 'en traitement') { 
        console.error(`Erreur: Statut de la demande (${demande.statut.nom}) n'est pas 'en traitement'.`);
        return res.status(400).json({ message: "La demande ne peut être validée que si elle est 'en traitement'." });
      }
  
      if (!demande.documentPath || !demande.verificationToken) {
        console.error("Erreur: Aucun document généré ou jeton de vérification pour cette demande.");
        return res.status(400).json({ message: "Aucun document généré pour cette demande." });
      }
      
      const citoyen = demande.citoyen;
      const donneesDemande = JSON.parse(demande.donneesJson || '{}');
      const typeDemande = demande.typeDemande;
      const currentDate = new Date().toLocaleDateString("fr-FR");
      
      // *** MODIFICATION ICI : Récupérer le nom du bourgmestre depuis req.user ***
      let bourgmestreName = 'Nom du Bourgmestre (Fallback)'; // Default fallback for clarity in logs
      console.log('DEBUG_AUTH: Contenu de req.user:', req.user); 

      if (req.user && req.user.role === 'admin') { // Changed 'bourgmestre' to 'admin'
        const bourgmestre = await Administrateur.findByPk(req.user.id);
        console.log('DEBUG_AUTH: Administrateur trouvé par req.user.id:', bourgmestre ? bourgmestre.toJSON() : 'Non trouvé');
        if (bourgmestre) {
          const prenom = bourgmestre.prenom || '';
          const nom = bourgmestre.nom || '';
          bourgmestreName = `${prenom} ${nom}`.trim();
          if (!bourgmestreName) { 
              bourgmestreName = 'Le Bourgmestre (Prénom/Nom vide dans Administrateur)';
          }
        } else {
            console.log('DEBUG_AUTH: Aucun administrateur trouvé pour req.user.id:', req.user.id);
            bourgmestreName = 'Le Bourgmestre (ID Admin non trouvé)';
        }
      } else {
        console.log('DEBUG_AUTH: Utilisateur non connecté comme bourgmestre ou rôle incorrect. Rôle:', req.user?.role || 'N/A');
        // Si l'utilisateur n'est pas bourgmestre, on ne signe pas avec son nom
        bourgmestreName = 'Nom du Bourgmestre (Non Authentifié)'; 
      }
      console.log('DEBUG_AUTH: Nom final du Bourgmestre pour signature:', bourgmestreName);
      // *************************************************************************

      // Re-use the original verification token for the signed document
      const verificationToken = demande.verificationToken; 
      const verificationUrl = `http://localhost:4000/verify-document?token=${verificationToken}`;
      const qrCodeDataURL = await qrcode.toDataURL(verificationUrl);
      console.log('Jeton de vérification et QR Code réutilisés.');

      let communeNaissanceEnfant = null;
      let provinceNaissanceEnfant = null;
      if (donneesDemande.communeNaissanceEnfantId) {
        communeNaissanceEnfant = await Commune.findByPk(donneesDemande.communeNaissanceEnfantId);
      }
      if (donneesDemande.provinceNaissanceEnfantId) {
        provinceNaissanceEnfant = await Province.findByPk(donneesDemande.provinceNaissanceEnfantId);
      }

      let htmlContent = ''; 
      // Define the signature block with dynamic name and desired styling
      const signatureBlockSigned = `
        <div class="signature-section" style="text-align: right; margin-top: 50px;">
          <p>Le Bourgmestre</p>
          <p class="bourgmestre-name" style="font-family: 'Brush Script MT', 'Lucida Handwriting', cursive; font-size: 1.4em; margin-top: 5px; font-weight: bold; color: #000;">
            ${bourgmestreName}
          </p>
        </div>
        <div class="qr-code" style="text-align: center; margin-top: 30px;">
          <img src="${qrCodeDataURL}" alt="QR Code de vérification" width="100" height="100">
        </div>
        <p class="verification-link" style="text-align: center; font-size: 0.9em; margin-top: 10px; color: #555;">Vérifiez l'authenticité : <a href="${verificationUrl}">${verificationUrl}</a></p>
      `;

      // Reconstruct the full HTML content, now including the signature
      switch (typeDemande) {
        case 'acte_naissance':
          htmlContent = `
            <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              h1 { color: #003da5; text-align: center; }
              .header, .footer { text-align: center; font-size: 0.8em; }
              .content { margin-top: 30px; line-height: 1.6; }
              .bourgmestre-name {
                font-family: 'Brush Script MT', 'Lucida Handwriting', cursive;
                font-size: 1.4em;
                margin-top: 5px;
                font-weight: bold;
                color: #000;
              }
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
              ${signatureBlockSigned}
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
              .bourgmestre-name {
                font-family: 'Brush Script MT', 'Lucida Handwriting', cursive;
                font-size: 1.4em;
                margin-top: 5px;
                font-weight: bold;
                color: #000;
              }
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
              ${signatureBlockSigned}
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
              .bourgmestre-name {
                font-family: 'Brush Script MT', 'Lucida Handwriting', cursive;
                font-size: 1.4em;
                margin-top: 5px;
                font-weight: bold;
                color: #000;
              }
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
              ${signatureBlockSigned}
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
              .card-layout { display: flex; border: 1px solid #ccc; padding: 20px; border-radius: 10px; max-width: 400px; margin: 20px auto; box-shadow: 2px 2px 8px rgba(0,0,0,0.1); }
              .card-left { flex: 1; text-align: center; padding-right: 20px; }
              .card-right { flex: 2; }
              .profile-pic { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 2px solid #003da5; }
              .card-info p { margin: 5px 0; }
              .bourgmestre-name {
                font-family: 'Brush Script MT', 'Lucida Handwriting', cursive;
                font-size: 1.4em;
                margin-top: 5px;
                font-weight: bold;
                color: #000;
              }
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
              ${signatureBlockSigned}
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
              ${signatureBlockSigned}
            </body>
          `;
      }

      console.log('Reconstruction et ajout de signature au contenu HTML.');
      
      const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
      const page = await browser.newPage();
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' }); // Attendre que le réseau soit inactif
      console.log('Contenu de la page avec signature défini.');

      const signedFilename = `${typeDemande}_${demande.id}_${verificationToken}_signed.pdf`;
      const signedPdfPath = path.join(DOCUMENTS_DIR, signedFilename);

      await fs.mkdir(DOCUMENTS_DIR, { recursive: true }); // Ensure directory exists
      console.log(`Tentative de génération du PDF signé vers: ${signedPdfPath}`);
      await page.pdf({ path: signedPdfPath, format: 'A4', printBackground: true });
      console.log('PDF signé généré avec succès.');

      await browser.close();
      console.log('Navigateur Puppeteer fermé.');

      const valideeStatutId = await getStatutIdByName('validée'); 
      if (!valideeStatutId) {
        throw new Error("Statut 'validée' non trouvé en base de données.");
      }

      await demande.update({
        statutId: valideeStatutId,
        documentPath: signedFilename // Sauvegarder le nom du fichier signé
      });
      console.log('Demande mise à jour en base de données avec le document signé et le statut "validée".');
  
      res.json({ message: "Document validé et signé avec succès !", documentUrl: `/documents/${signedFilename}` });
      console.log('--- Fin de la fonction validateDocument (Succès) ---');

    } catch (error) {
      console.error("--- Erreur CRITIQUE lors de la validation et signature du document ---");
      console.error("Détails de l'erreur:", error);
      if (error.stack) {
        console.error("Stack Trace:", error.stack);
      }
      res.status(500).json({ message: "Erreur serveur lors de la validation et signature.", error: error.message });
      console.log('--- Fin de la fonction validateDocument (Échec) ---');
    }
  },
  // A ajouter dans le module.exports de votre demandeController.js
  async downloadDocument(req, res) {
    try {
      const { id } = req.params;
      const demande = await Demande.findByPk(id);
  
      if (!demande || !demande.documentPath) {
        return res.status(404).json({ message: "Document non trouvé." });
      }
  
      // Assurez-vous que le citoyen a le droit de télécharger son propre document
      if (req.user.role !== 'admin' && req.user.id !== demande.citoyenId) {
        return res.status(403).json({ message: "Accès interdit." });
      }
  
      const filePath = path.join(DOCUMENTS_DIR, demande.documentPath);
  
      // Vérifie si le fichier existe
      await fs.access(filePath);
      
      // Envoie le fichier au client
      res.download(filePath, (err) => {
        if (err) {
          console.error('Erreur lors de l\'envoi du fichier:', err);
          res.status(500).json({ message: "Erreur serveur lors du téléchargement." });
        }
      });
  
    } catch (error) {
      console.error('Erreur downloadDocument:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },
  // ... après les autres fonctions existantes
  
  async getValidatedDocuments(req, res) {
    try {
      if (!req.user || req.user.role !== 'citoyen') {
        return res.status(403).json({ message: 'Accès interdit: Seuls les citoyens peuvent consulter leurs documents validés.' });
      }
  
      // On récupère l'ID du statut 'valide' ou 'validé'
      const validatedStatut = await Statut.findOne({ where: { nom: 'validée' } });
      if (!validatedStatut) {
        return res.status(404).json({ message: 'Statut de validation non trouvé.' });
      }
  
      // On cherche les demandes du citoyen connecté qui ont le statut 'valide'
      const demandes = await Demande.findAll({
        where: { 
          citoyenId: req.user.id,
          statutId: validatedStatut.id // On filtre par l'ID du statut 'valide'
        },
        include: [{ model: Statut, as: 'statut' }],
        order: [['updatedAt', 'DESC']]
      });
  
      res.json(demandes);
  
    } catch (error) {
      console.error('Erreur getValidatedDocuments:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
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
