const pool = require('../db');

// GET toutes les compagnies (optionnellement filtrées par ville et nom)
exports.getAll = async (req, res) => {
    const { villeId, nom } = req.query;
    try {
        let query = `
            SELECT c.*, v.nom AS ville_nom
            FROM compagnies c
            JOIN villes v ON c.ville_id = v.id
            WHERE 1=1
        `;
        const values = [];

        if (villeId) {
            values.push(villeId);
            query += ` AND c.ville_id = $${values.length}`;
        }

        if (nom) {
            values.push(`%${nom}%`);
            query += ` AND c.nom ILIKE $${values.length}`;
        }

        const result = await pool.query(query, values);
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Erreur getAll compagnies:', err);
        res.status(500).json({ erreur: 'Erreur lors de la récupération des compagnies' });
    }
};

// GET une compagnie par ID
exports.getById = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM compagnies WHERE id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ erreur: 'Compagnie non trouvée' });
        }
        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('Erreur getById compagnie:', err);
        res.status(500).json({ erreur: 'Erreur lors de la récupération de la compagnie' });
    }
};

// POST créer une compagnie
exports.create = async (req, res) => {
  const { nom, telephone, email, logo_url, adresse, description, ville_id } = req.body;

  try {
    // Affiche ce que tu reçois, pour debug
    console.log('Données reçues pour création compagnie:', req.body);

    const result = await pool.query(
      `INSERT INTO compagnies (nom, telephone, email, logo_url, adresse, description, ville_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [nom, telephone, email, logo_url, adresse, description, ville_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Erreur create compagnie:', err);
    res.status(500).json({ erreur: 'Erreur lors de la création de la compagnie' });
  }
};

// PUT mettre à jour une compagnie

exports.update = async (req, res) => {
  const { id } = req.params;

  // Debug crucial
  console.log('[DEBUG] Headers:', req.headers);
  console.log('[DEBUG] Body:', req.body);

  if (!req.body || Object.keys(req.body).length === 0) {
    return res.status(400).json({ 
      erreur: "Le corps de la requête est manquant ou vide.",
      solution: "Assurez-vous d'envoyer un JSON valide avec le header Content-Type: application/json"
    });
  }

  // Vérification des champs requis selon votre schéma SQL
  const requiredFields = ['nom', 'ville_id'];
  const missingFields = requiredFields.filter(field => !req.body[field]);

  if (missingFields.length > 0) {
    return res.status(400).json({
      erreur: "Champs obligatoires manquants",
      champs_requis: requiredFields,
      champs_manquants: missingFields
    });
  }

  try {
    const { nom, telephone, email, logo_url, adresse, description, ville_id } = req.body;

    const result = await pool.query(
      `UPDATE compagnies SET 
        nom = COALESCE($1, nom),
        telephone = COALESCE($2, telephone),
        email = COALESCE($3, email),
        logo_url = COALESCE($4, logo_url),
        adresse = COALESCE($5, adresse),
        description = COALESCE($6, description),
        ville_id = COALESCE($7, ville_id)
       WHERE id = $8
       RETURNING *`,
      [nom, telephone, email, logo_url, adresse, description, ville_id, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ erreur: 'Aucune compagnie trouvée avec cet ID' });
    }

    res.status(200).json({
      message: 'Compagnie mise à jour avec succès',
      data: result.rows[0]
    });
  } catch (err) {
    console.error('Erreur SQL:', err);
    res.status(500).json({ 
      erreur: 'Erreur lors de la mise à jour',
      details: err.message,
      conseil: "Vérifiez que le ville_id existe dans la table villes"
    });
  }
};


// DELETE supprimer une compagnie
exports.delete = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('DELETE FROM compagnies WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ erreur: 'Compagnie non trouvée' });
        }
        res.status(200).json({ message: 'Compagnie supprimée' });
    } catch (err) {
        console.error('Erreur delete compagnie:', err);
        res.status(500).json({ erreur: 'Erreur lors de la suppression de la compagnie' });
    }
};

// GET compagnies par ville (ex: /api/compagnies/ville/1)
exports.getCompagniesByVille = async (req, res) => {
    const { villeId } = req.params;
    try {
        const result = await pool.query(
            `SELECT c.*, v.nom AS ville_nom
             FROM compagnies c
             JOIN villes v ON c.ville_id = v.id
             WHERE c.ville_id = $1`,
            [villeId]
        );
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Erreur getCompagniesByVille:', err);
        res.status(500).json({ erreur: 'Erreur lors de la récupération des compagnies par ville' });
    }
};
