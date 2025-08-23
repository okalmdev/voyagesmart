// === controllers/authController.js ===
const pool = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'secret123';

// Inscription
exports.register = async (req, res) => {
  const { nom, email, telephone, mot_de_passe, role } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
    const result = await pool.query(
      'INSERT INTO utilisateurs (nom, email, telephone, mot_de_passe, role) VALUES ($1, $2, $3, $4, $5) RETURNING id, nom, email, telephone, role',
      [nom, email, telephone, hashedPassword, role]
    );
    res.status(201).json({ utilisateur: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur lors de l’inscription' });
  }
};

// Connexion
exports.login = async (req, res) => {
  const { email, mot_de_passe } = req.body;

  try {
    const result = await pool.query('SELECT * FROM utilisateurs WHERE email = $1', [email]);
    const utilisateur = result.rows[0];

    if (!utilisateur) {
      return res.status(400).json({ error: 'Utilisateur non trouvé' });
    }

    const valid = await bcrypt.compare(mot_de_passe, utilisateur.mot_de_passe);
    if (!valid) {
      return res.status(400).json({ error: 'Mot de passe incorrect' });
    }

    const token = jwt.sign({ userId: utilisateur.id, role: utilisateur.role }, SECRET, { expiresIn: '7d' });

    res.json({
      token,
      utilisateur: {
        id: utilisateur.id,
        nom: utilisateur.nom,
        email: utilisateur.email,
        role: utilisateur.role
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};
