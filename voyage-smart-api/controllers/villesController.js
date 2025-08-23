const db = require('../db'); // adapte le chemin selon ton projet

const villesController = {
  // Obtenir toutes les villes
  getAllVilles: async (req, res) => {
    try {
      const result = await db.query('SELECT * FROM villes');
      res.status(200).json(result.rows);
    } catch (err) {
      console.error(err);
      res.status(500).json({ erreur: 'Erreur lors de la récupération des villes' });
    }
  },

  // Obtenir une ville par son ID
  getVilleById: async (req, res) => {
    const { villeId } = req.params;
    try {
      const result = await db.query('SELECT * FROM villes WHERE id = $1', [villeId]);
      if (result.rows.length === 0) {
        return res.status(404).json({ erreur: 'Ville non trouvée' });
      }
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ erreur: 'Erreur lors de la récupération de la ville' });
    }
  },

  // Créer une nouvelle ville
  createVille: async (req, res) => {
    const { nom, latitude, longitude } = req.body;
    try {
      const result = await db.query(
        'INSERT INTO villes (nom, latitude, longitude) VALUES ($1, $2, $3) RETURNING *',
        [nom, latitude, longitude]
      );
      res.status(201).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ erreur: 'Erreur lors de la création de la ville' });
    }
  },

  // Mettre à jour une ville
  updateVille: async (req, res) => {
    const { villeId } = req.params;
    const { nom, latitude, longitude } = req.body;
    try {
      const result = await db.query(
        'UPDATE villes SET nom = $1, latitude = $2, longitude = $3 WHERE id = $4 RETURNING *',
        [nom, latitude, longitude, villeId]
      );
      if (result.rows.length === 0) {
        return res.status(404).json({ erreur: 'Ville non trouvée pour mise à jour' });
      }
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ erreur: 'Erreur lors de la mise à jour de la ville' });
    }
  },

  // Supprimer une ville
  deleteVille: async (req, res) => {
    const { villeId } = req.params;
    try {
      const result = await db.query('DELETE FROM villes WHERE id = $1 RETURNING *', [villeId]);
      if (result.rows.length === 0) {
        return res.status(404).json({ erreur: 'Ville non trouvée pour suppression' });
      }
      res.status(200).json({ message: 'Ville supprimée avec succès' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ erreur: 'Erreur lors de la suppression de la ville' });
    }
  }
};

module.exports = villesController;
