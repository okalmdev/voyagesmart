const pool = require('../db');

// Fonction helper pour les suggestions alternatives
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
  // Récupérer tous les voyages de bus
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

// Réserver un bus
reserveBus: async (req, res) => {
  const { utilisateur_id, voyage_id, date_reservation, numero_place, prix } = req.body;
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    // 1. Vérifier si le voyage existe dans voyages_bus
    const voyageCheck = await client.query(
      `SELECT id FROM voyages_bus WHERE id = $1`,
      [voyage_id]
    );

    if (voyageCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ 
        erreur: 'Voyage non trouvé.' 
      });
    }

    const placeNumber = numero_place.toString();

    // 2. Vérifier si le siège est déjà réservé
    const seatCheck = await client.query(
      `SELECT id FROM reservations_bus 
       WHERE voyage_id = $1 AND numero_place = $2 
       AND statut IN ('en attente', 'confirmé')`,
      [voyage_id, placeNumber]
    );

    if (seatCheck.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.status(409).json({ 
        erreur: `Le siège ${placeNumber} est déjà réservé.` 
      });
    }

    // 3. Créer la réservation
    const reservationResult = await client.query(
      `INSERT INTO reservations_bus 
       (utilisateur_id, voyage_id, date_reservation, numero_place, prix, statut)
       VALUES ($1, $2, $3, $4, $5, 'confirmé') 
       RETURNING id`,
      [utilisateur_id, voyage_id, date_reservation, placeNumber, prix]
    );

    await client.query('COMMIT');
    
    const reservationId = reservationResult.rows[0].id;
    
    // ✅ ENVOYER UN JSON VALIDE
    res.status(201).json({ 
      message: 'Réservation effectuée avec succès.',
      reservation_id: reservationId
    });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Erreur réservation bus:', err);
    
    // ✅ ENVOYER UN JSON VALIDE MÊME EN CAS D'ERREUR
    res.status(500).json({ 
      erreur: 'Erreur lors de la réservation de bus.'
    });
  } finally {
    client.release();
  }
},

  // Annuler une réservation
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
      res.json({ message: '❌ Réservation de bus annulée.', reservation: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de l\'annulation.' });
    }
  },

  // Terminer une réservation
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

  // Récupérer les programmes du jour
  getDailyPrograms: async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT 
          vb.id,
          vb.numero_bus,
          c1.nom AS ville_depart,
          c2.nom AS ville_arrivee,
          vb.heure_depart,
          vb.heure_arrivee,
          vb.prix
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        WHERE DATE(vb.heure_depart) = CURRENT_DATE
        ORDER BY vb.heure_depart ASC
      `);
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la récupération des programmes du jour.' });
    }
  },

  // Récupérer un programme de bus par son ID
  getBusProgramById: async (req, res) => {
    const { busId } = req.params;
    try {
      const result = await pool.query(`
        SELECT 
          vb.id,
          vb.numero_bus,
          c1.nom AS ville_depart,
          c2.nom AS ville_arrivee,
          vb.heure_depart,
          vb.heure_arrivee,
          vb.prix
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        WHERE vb.id = $1
      `, [busId]);

      if (result.rows.length === 0) {
        return res.status(404).json({ erreur: 'Bus non trouvé ou programme inexistant.' });
      }

      res.json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la récupération du programme.' });
    }
  },

  // Récupérer le programme d'une compagnie par son nom
  getCompanyProgram: async (req, res) => {
    const nomCompagnie = decodeURIComponent(req.params.nomCompagnie);

    try {
      const compagnieCheck = await pool.query(
        `SELECT id, nom FROM compagnies WHERE LOWER(nom) = LOWER($1)`,
        [nomCompagnie]
      );

      if (compagnieCheck.rows.length === 0) {
        return res.status(404).json({ erreur: `❌ Compagnie '${nomCompagnie}' introuvable.` });
      }

      const compagnieId = compagnieCheck.rows[0].id;

      const result = await pool.query(`
        SELECT 
          vb.id AS bus_id,
          vb.numero_bus,
          vb.prix,
          vb.nombre_places,
          vb.heure_depart,
          vb.heure_arrivee,
          vb.description,
          c1.nom AS ville_depart,
          c2.nom AS ville_arrivee,
          comp.nom AS compagnie,
          COUNT(rb.id) FILTER (WHERE rb.statut != 'annulée') AS places_reservees,
          vb.nombre_places - COUNT(rb.id) FILTER (WHERE rb.statut != 'annulée') AS places_restantes
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        JOIN compagnies comp ON vb.compagnie_id = comp.id
        LEFT JOIN reservations_bus rb ON vb.id = rb.voyage_id
        WHERE vb.compagnie_id = $1
        GROUP BY vb.id, c1.nom, c2.nom, comp.nom
        ORDER BY vb.heure_depart ASC
      `, [compagnieId]);

      res.json(result.rows);
    } catch (err) {
      console.error('Erreur programme compagnie:', err);
      res.status(500).json({ erreur: 'Erreur lors de la récupération du programme de la compagnie.' });
    }
  },

  // Recherche de voyages en fonction des critères (version améliorée)
  searchTrips: async (req, res) => {
    console.log("🔍 Paramètres de recherche reçus:", req.body);
    
    if (!req.body || !req.body.ville_depart || !req.body.ville_arrivee || !req.body.date_depart) {
      return res.status(400).json({ 
        erreur: 'Paramètres manquants',
        details: 'Les champs ville_depart, ville_arrivee et date_depart sont obligatoires'
      });
    }

    const { ville_depart, ville_arrivee, date_depart } = req.body;

    try {
      // Vérification que les villes existent
      const villeCheck = await pool.query(
        `SELECT id, nom FROM villes WHERE LOWER(nom) IN (LOWER($1), LOWER($2))`,
        [ville_depart, ville_arrivee]
      );

      if (villeCheck.rows.length < 2) {
        const villesTrouvees = villeCheck.rows.map(v => v.nom);
        const villesManquantes = [ville_depart, ville_arrivee]
          .filter(v => !villesTrouvees.includes(v.toLowerCase()));
        
        return res.status(404).json({ 
          erreur: 'Ville(s) non trouvée(s)',
          villes_manquantes: villesManquantes
        });
      }

      // Formatage de la date
      const dateFormatee = new Date(date_depart);
      if (isNaN(dateFormatee.getTime())) {
        return res.status(400).json({ 
          erreur: 'Format de date invalide',
          format_requis: 'YYYY-MM-DD'
        });
      }

      // Recherche des trajets
      const result = await pool.query(`
        SELECT 
          vb.id,
          vb.numero_bus,
          comp.nom AS compagnie,
          vb.prix,
          vb.nombre_places,
          vb.heure_depart,
          vb.heure_arrivee,
          vb.description,
          c1.nom AS ville_depart,
          c2.nom AS ville_arrivee,
          COUNT(rb.id) FILTER (WHERE rb.statut != 'annulée') AS places_reservees,
          vb.nombre_places - COUNT(rb.id) FILTER (WHERE rb.statut != 'annulée') AS places_restantes,
          CASE 
            WHEN vb.nombre_places - COUNT(rb.id) FILTER (WHERE rb.statut != 'annulée') <= 0 
            THEN 'COMPLET'
            ELSE 'DISPONIBLE'
          END AS statut
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        JOIN compagnies comp ON vb.compagnie_id = comp.id
        LEFT JOIN reservations_bus rb ON vb.id = rb.voyage_id
        WHERE LOWER(c1.nom) = LOWER($1)
          AND LOWER(c2.nom) = LOWER($2)
          AND DATE(vb.heure_depart) = $3
        GROUP BY vb.id, c1.nom, c2.nom, comp.nom
        ORDER BY vb.heure_depart ASC
      `, [ville_depart, ville_arrivee, dateFormatee.toISOString().split('T')[0]]);

      if (result.rows.length === 0) {
        const suggestions = await getAlternativeTrips(ville_depart, ville_arrivee, dateFormatee);
        return res.status(200).json({
          message: 'Aucun trajet direct trouvé',
          suggestions: suggestions
        });
      }

      res.json(result.rows);
    } catch (err) {
      console.error('🔥 Erreur recherche:', err.stack);
      res.status(500).json({ 
        erreur: 'Erreur technique',
        details: process.env.NODE_ENV === 'development' ? err.message : null
      });
    }
  },

  // Récupérer les départs depuis une ville donnée
  getDeparturesFromCity: async (req, res) => {
    const { ville } = req.params;
    try {
      const result = await pool.query(`
        SELECT 
          vb.id AS bus_id,
          vb.numero_bus,
          vb.prix,
          vb.nombre_places,
          vb.heure_depart,
          vb.heure_arrivee,
          c1.nom AS ville_depart,
          c2.nom AS ville_arrivee,
          COALESCE(COUNT(rb.id), 0) AS places_reservees,
          vb.nombre_places - COALESCE(COUNT(rb.id), 0) AS places_restantes
        FROM voyages_bus vb
        JOIN villes c1 ON vb.ville_depart_id = c1.id
        JOIN villes c2 ON vb.ville_arrivee_id = c2.id
        LEFT JOIN reservations_bus rb ON vb.id = rb.voyage_id AND rb.statut != 'annulée'
        WHERE LOWER(c1.nom) = LOWER($1)
        GROUP BY vb.id, c1.nom, c2.nom
        ORDER BY vb.heure_depart ASC
      `, [ville]);
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la récupération des départs.' });
    }
  }
};

module.exports = busController;