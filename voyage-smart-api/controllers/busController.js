const pool = require('../db');

// Fonction helper pour suggestions alternatives
async function getAlternativeTrips(villeDep, villeArr, date) {
  try {
    const result = await pool.query(`
      SELECT 
        c1.nom AS ville_depart,
        c2.nom AS ville_arrivee,
        COUNT(vb.id) AS nombre_trajets
      FROM voyages_bus vb
      JOIN villes c1 ON vb.ville_depart_id = c1.id
      JOIN villes c2 ON vb.ville_arrivee_id = c2.id
      WHERE DATE(vb.heure_depart) = $1
        AND (LOWER(c1.nom) LIKE LOWER($2) OR LOWER(c2.nom) LIKE LOWER($3))
      GROUP BY c1.nom, c2.nom
      ORDER BY nombre_trajets DESC
      LIMIT 5
    `, [date, `%${villeDep}%`, `%${villeArr}%`]);
    
    return result.rows;
  } catch (err) {
    console.error('Erreur suggestions:', err);
    return [];
  }
}

const busController = {
  // 🔹 Récupérer tous les voyages de bus
  getAllTrips: async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT vb.id, vb.numero_bus, c1.nom AS ville_depart, c2.nom AS ville_arrivee,
               vb.heure_depart, vb.heure_arrivee, vb.prix, vb.nombre_places
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        ORDER BY vb.heure_depart ASC
      `);
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: err.message });
    }
  },

  // 🔹 Réserver un bus (multi-sièges optimisé)
  reserveBus: async (req, res) => {
    const { utilisateur_id, voyage_id, date_reservation, numero_place, prix } = req.body;
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // Vérifier que le voyage existe
      const voyageCheck = await client.query(
        `SELECT id, nombre_places FROM voyages_bus WHERE id = $1`,
        [voyage_id]
      );
      if (voyageCheck.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ erreur: 'Voyage non trouvé.' });
      }

      // Convertir en tableau si on reçoit une string "1,2,3" ou "A1,B2"
      const places = Array.isArray(numero_place)
        ? numero_place
        : numero_place.split(',').map(p => p.trim());

      if (places.length === 0) {
        await client.query('ROLLBACK');
        return res.status(400).json({ erreur: 'Aucun siège fourni.' });
      }

      // Vérifier si certains sièges sont déjà réservés
      const seatCheck = await client.query(
        `SELECT numero_place FROM reservations_bus
         WHERE voyage_id = $1
         AND numero_place = ANY($2)
         AND statut IN ('en attente', 'confirmé')`,
        [voyage_id, places]
      );

      if (seatCheck.rows.length > 0) {
        await client.query('ROLLBACK');
        return res.status(409).json({
          erreur: 'Certains sièges sont déjà réservés.',
          deja_reserves: seatCheck.rows.map(r => r.numero_place)
        });
      }

      // Construire un seul INSERT pour tous les sièges
      const values = [];
      const params = [];
      let paramIndex = 1;
      places.forEach((place, i) => {
        values.push(`($${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++}, 'confirmé')`);
        params.push(utilisateur_id, voyage_id, date_reservation || new Date(), place, prix / places.length);
      });

      const insertQuery = `
        INSERT INTO reservations_bus 
        (utilisateur_id, voyage_id, date_reservation, numero_place, prix, statut)
        VALUES ${values.join(', ')}
        RETURNING id, utilisateur_id, voyage_id, numero_place, date_reservation, prix, statut
      `;

      const reservationResult = await client.query(insertQuery, params);

      await client.query('COMMIT');

      res.status(201).json({
        message: '✅ Réservation effectuée avec succès.',
        reservations: reservationResult.rows
      });

    } catch (err) {
      await client.query('ROLLBACK');
      console.error('Erreur réservation bus:', err);
      res.status(500).json({ erreur: 'Erreur lors de la réservation de bus.' });
    } finally {
      client.release();
    }
  },

  // 🔹 Annuler une réservation
  cancelReservation: async (req, res) => {
    const { reservationId } = req.params;
    try {
      const result = await pool.query(
        `UPDATE reservations_bus SET statut = 'annulée' WHERE id = $1 RETURNING *`,
        [reservationId]
      );
      if (result.rowCount === 0) {
        return res.status(404).json({ erreur: 'Réservation non trouvée.' });
      }
      res.json({ message: '❌ Réservation annulée.', reservation: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de l\'annulation.' });
    }
  },

  // 🔹 Terminer une réservation
  terminerReservation: async (req, res) => {
    const { reservationId } = req.params;
    try {
      const result = await pool.query(
        `UPDATE reservations_bus SET statut = 'terminée' WHERE id = $1 RETURNING *`,
        [reservationId]
      );
      if (result.rowCount === 0) {
        return res.status(404).json({ erreur: 'Réservation non trouvée.' });
      }
      res.json({ message: '✅ Trajet terminé.', reservation: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la mise à jour.' });
    }
  },

  // 🔹 Les autres méthodes (getDailyPrograms, getBusProgramById, searchTrips...) restent inchangées
  getDailyPrograms: async (req, res) => { /* ... */ },
  getBusProgramById: async (req, res) => { /* ... */ },
  getCompanyProgram: async (req, res) => { /* ... */ },
  searchTrips: async (req, res) => { /* ... */ },
  getDeparturesFromCity: async (req, res) => { /* ... */ }
};

module.exports = busController;
