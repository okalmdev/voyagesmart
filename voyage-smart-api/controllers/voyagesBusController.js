const pool = require('../db');

// ✅ Lire tous les voyages
exports.getAllBusTrips = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        vb.id, vb.numero_bus, vb.heure_depart, vb.heure_arrivee,
        c1.nom AS ville_depart, c2.nom AS ville_arrivee,
        co.nom AS compagnie, vb.prix, vb.nombre_places, vb.description
      FROM voyages_bus vb
      JOIN villes c1 ON vb.ville_depart_id = c1.id
      JOIN villes c2 ON vb.ville_arrivee_id = c2.id
      JOIN compagnies co ON vb.compagnie_id = co.id
      ORDER BY vb.heure_depart ASC;
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des voyages :', error);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
};

// ✅ Créer un voyage
exports.createBusTrip = async (req, res) => {
  const {
    ville_depart_id,
    ville_arrivee_id,
    compagnie_id,
    numero_bus,
    heure_depart,
    heure_arrivee,
    prix,
    nombre_places,
    description
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO voyages_bus (
        ville_depart_id, ville_arrivee_id, compagnie_id,
        numero_bus, heure_depart, heure_arrivee, prix,
        nombre_places, description
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
      [ville_depart_id, ville_arrivee_id, compagnie_id, numero_bus, heure_depart, heure_arrivee, prix, nombre_places, description]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la création du voyage :', error);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
};

// ✅ Modifier un voyage
exports.updateBusTrip = async (req, res) => {
  const { id } = req.params;
  const {
    ville_depart_id,
    ville_arrivee_id,
    compagnie_id,
    numero_bus,
    heure_depart,
    heure_arrivee,
    prix,
    nombre_places,
    description
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE voyages_bus SET
        ville_depart_id = $1,
        ville_arrivee_id = $2,
        compagnie_id = $3,
        numero_bus = $4,
        heure_depart = $5,
        heure_arrivee = $6,
        prix = $7,
        nombre_places = $8,
        description = $9
      WHERE id = $10
      RETURNING *`,
      [ville_depart_id, ville_arrivee_id, compagnie_id, numero_bus, heure_depart, heure_arrivee, prix, nombre_places, description, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ erreur: 'Voyage non trouvé' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la mise à jour du voyage :', error);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
};

// ✅ Supprimer un voyage (corrigé ici)
exports.deleteBusTrip = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`DELETE FROM voyages_bus WHERE id = $1 RETURNING *`, [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ erreur: 'Voyage non trouvé' });
    }

    res.json({ message: 'Voyage supprimé avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression du voyage :', error);
    res.status(500).json({ erreur: 'Erreur serveur' });
  }
};
