const pool = require('../db');
const bcrypt = require('bcryptjs');

const userController = {
  // Lire tous les utilisateurs (sans mot_de_passe)
  getAllUsers: async (req, res) => {
    try {
      const result = await pool.query('SELECT id, nom, email, telephone, role, compagnie_id FROM utilisateurs');
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // Lire un utilisateur par son ID
  getUserById: async (req, res) => {
    const { userId } = req.params;
    try {
      const result = await pool.query('SELECT id, nom, email, telephone, role, compagnie_id FROM utilisateurs WHERE id = $1', [userId]);
      if (result.rows.length === 0) return res.status(404).json({ error: 'Utilisateur non trouvé' });
      res.json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // Créer un utilisateur (inscription)
  createUser: async (req, res) => {
    const { nom, email, telephone, mot_de_passe, role, compagnie_id } = req.body;
    try {
      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

      const result = await pool.query(
        `INSERT INTO utilisateurs (nom, email, telephone, mot_de_passe, role, compagnie_id)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, nom, email, telephone, role, compagnie_id`,
        [nom, email, telephone, hashedPassword, role || 'utilisateur', compagnie_id || null]
      );
      res.status(201).json({ message: 'Utilisateur créé avec succès', user: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: 'Erreur lors de la création de l\'utilisateur' });
    }
  },

  // Mettre à jour un utilisateur (nom, email, telephone, role, compagnie_id)
  updateUser: async (req, res) => {
    const { userId } = req.params;
    const { nom, email, telephone, role, compagnie_id } = req.body;

    try {
      const result = await pool.query(
        `UPDATE utilisateurs 
         SET nom = $1, email = $2, telephone = $3, role = $4, compagnie_id = $5
         WHERE id = $6
         RETURNING id, nom, email, telephone, role, compagnie_id`,
        [nom, email, telephone, role, compagnie_id, userId]
      );
      if (result.rowCount === 0) return res.status(404).json({ error: 'Utilisateur non trouvé' });
      res.json({ message: 'Utilisateur mis à jour', user: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // Supprimer un utilisateur
  deleteUser: async (req, res) => {
    const { userId } = req.params;
    try {
      const result = await pool.query('DELETE FROM utilisateurs WHERE id = $1 RETURNING *', [userId]);
      if (result.rowCount === 0) return res.status(404).json({ error: 'Utilisateur non trouvé' });
      res.json({ message: 'Utilisateur supprimé avec succès' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
};

module.exports = userController;
