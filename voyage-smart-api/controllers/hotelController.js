const db = require('../db');

const hotelController = {
  // Récupérer tous les hôtels (avec ou sans filtre par ville)
  getAllHotels: async (req, res) => {
    const { villeId } = req.query;
    try {
      const result = villeId
        ? await db.query(`SELECT * FROM hotels WHERE ville_id = $1`, [villeId])
        : await db.query('SELECT * FROM hotels');
      res.status(200).json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la récupération des hôtels.' });
    }
  },

  // Récupérer les hôtels par nom de ville (facultatif)
  getHotelsByCity: async (req, res) => {
    const { ville } = req.query;
    try {
      const result = await db.query(`
        SELECT h.*
        FROM hotels h
        JOIN villes v ON h.ville_id = v.id
        WHERE LOWER(v.nom) = LOWER($1)
      `, [ville]);
      res.status(200).json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: 'Erreur lors de la recherche des hôtels par ville.' });
    }
  },

//hotels recommendés selon la ville
getRecommendedHotels: async (req, res) => {
  const { ville } = req.query;

  if (!ville) {
    return res.status(400).json({ erreur: "Le champ 'ville' est requis." });
  }

  try {
    const result = await db.query(`
      SELECT h.*
      FROM hotels h
      JOIN villes v ON h.ville_id = v.id
      WHERE LOWER(v.nom) = LOWER($1)
      ORDER BY h.rating DESC NULLS LAST, h.prix_moyen ASC NULLS LAST
      LIMIT 5
    `, [ville]);

    res.status(200).json({
      message: "✅ Hôtels recommandés récupérés avec succès.",
      hotels: result.rows
    });
  } catch (err) {
    console.error("❌ Erreur lors de la récupération des hôtels recommandés :", err);
    res.status(500).json({ erreur: "Erreur lors de la récupération des hôtels recommandés." });
  }
},


  // Ajouter un hôtel
  addHotel: async (req, res) => {
    const { nom, adresse, telephone, email, description, latitude, longitude, ville_id } = req.body;
    try {
      const result = await db.query(`
        INSERT INTO hotels (nom, adresse, telephone, email, description, latitude, longitude, ville_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *
      `, [nom, adresse, telephone, email, description, latitude, longitude, ville_id]);
      res.status(201).json({ message: '✅ Hôtel ajouté avec succès.', hotel: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de l'ajout de l'hôtel." });
    }
  },

  // Modifier un hôtel
  updateHotel: async (req, res) => {
    const { id } = req.params;
    const { nom, adresse, telephone, email, description, latitude, longitude, ville_id } = req.body;
    try {
      const result = await db.query(`
        UPDATE hotels
        SET nom = $1, adresse = $2, telephone = $3, email = $4, description = $5,
            latitude = $6, longitude = $7, ville_id = $8
        WHERE id = $9 RETURNING *
      `, [nom, adresse, telephone, email, description, latitude, longitude, ville_id, id]);

      if (result.rowCount === 0) return res.status(404).json({ message: 'Hôtel non trouvé.' });
      res.status(200).json({ message: '✅ Hôtel modifié avec succès.', hotel: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la modification de l'hôtel." });
    }
  },

  // Supprimer un hôtel
  deleteHotel: async (req, res) => {
    const { id } = req.params;
    try {
      const result = await db.query(`DELETE FROM hotels WHERE id = $1 RETURNING *`, [id]);
      if (result.rowCount === 0) return res.status(404).json({ message: 'Hôtel non trouvé.' });
      res.status(200).json({ message: '🗑️ Hôtel supprimé avec succès.', hotel: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la suppression de l'hôtel." });
    }
  },

  // Réserver un hôtel
reserveHotel: async (req, res) => {
  const {
    hotel_id,
    date_arrivee,
    date_depart,
    type_chambre,
    nombre_personnes
  } = req.body;

  const utilisateur_id = req.user.userId; // Utilisateur connecté via token

  if (!hotel_id || !date_arrivee || !date_depart || !type_chambre || !nombre_personnes) {
    return res.status(400).json({ erreur: "❌ Tous les champs sont obligatoires." });
  }

  const dArrivee = new Date(date_arrivee);
  const dDepart = new Date(date_depart);

  if (isNaN(dArrivee) || isNaN(dDepart)) {
    return res.status(400).json({ erreur: "❌ Les dates ne sont pas valides." });
  }

  if (dArrivee >= dDepart) {
    return res.status(400).json({ erreur: "❌ La date de départ doit être après la date d'arrivée." });
  }

  try {
    const hotelResult = await db.query(`SELECT id FROM hotels WHERE id = $1`, [hotel_id]);
    if (hotelResult.rowCount === 0) {
      return res.status(404).json({ erreur: "❌ Hôtel non trouvé." });
    }

    const now = new Date();

    await db.query(`
      INSERT INTO reservations_hotel 
      (hotel_id, utilisateur_id, date_arrivee, date_depart, type_chambre, nombre_personnes, statut, date_reservation)
      VALUES ($1, $2, $3, $4, $5, $6, 'confirmée', $7)
    `, [hotel_id, utilisateur_id, date_arrivee, date_depart, type_chambre, nombre_personnes, now]);

    return res.status(201).json({ message: "✅ Réservation enregistrée avec succès." });

  } catch (err) {
    console.error("❌ Erreur lors de la réservation :", err);
    return res.status(500).json({ erreur: "❌ Une erreur est survenue lors de la réservation." });
  }
},



  // Modifier une réservation
  updateReservation: async (req, res) => {
    const { reservationId } = req.params;
    const { date_arrivee, date_depart, type_chambre, nombre_personnes } = req.body;
    try {
      const check = await db.query(`SELECT * FROM reservations_hotel WHERE id = $1`, [reservationId]);
      if (check.rowCount === 0) return res.status(404).json({ message: 'Réservation non trouvée.' });
      if (['annulée', 'terminée'].includes(check.rows[0].statut)) {
        return res.status(403).json({ erreur: 'Impossible de modifier une réservation annulée ou terminée.' });
      }
      await db.query(`
        UPDATE reservations_hotel
        SET date_arrivee = $1, date_depart = $2, type_chambre = $3, nombre_personnes = $4
        WHERE id = $5
      `, [date_arrivee, date_depart, type_chambre, nombre_personnes, reservationId]);
      res.status(200).json({ message: '🔁 Réservation modifiée avec succès.' });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la modification de la réservation." });
    }
  },

  // Annuler une réservation
  cancelReservation: async (req, res) => {
    const { reservationId } = req.params;
    try {
      const result = await db.query(`
        UPDATE reservations_hotel SET statut = 'annulée' WHERE id = $1 RETURNING *
      `, [reservationId]);
      if (result.rowCount === 0) return res.status(404).json({ message: 'Réservation non trouvée.' });
      res.status(200).json({ message: '❌ Réservation annulée avec succès.', reservation: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de l'annulation." });
    }
  },

  // Terminer une réservation
  terminerReservation: async (req, res) => {
    const { reservationId } = req.params;
    try {
      const result = await db.query(`
        UPDATE reservations_hotel SET statut = 'terminée' WHERE id = $1 RETURNING *
      `, [reservationId]);
      if (result.rowCount === 0) return res.status(404).json({ message: 'Réservation non trouvée.' });
      res.status(200).json({ message: '✅ Séjour terminé avec succès.', reservation: result.rows[0] });
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la mise à jour du statut." });
    }
  },

  // Récupérer toutes les réservations
  getAllReservations: async (req, res) => {
    try {
      const result = await db.query(`
        SELECT rh.*, h.nom AS nom_hotel, u.nom AS nom_utilisateur
        FROM reservations_hotel rh
        JOIN hotels h ON rh.hotel_id = h.id
        JOIN utilisateurs u ON rh.utilisateur_id = u.id
        ORDER BY rh.id DESC
      `);
      res.status(200).json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la récupération des réservations." });
    }
  },

  // Récupérer les réservations d'un utilisateur
  getReservationsByUser: async (req, res) => {
    const { utilisateurId } = req.params;
    try {
      const result = await db.query(`
        SELECT rh.*, h.nom AS nom_hotel
        FROM reservations_hotel rh
        JOIN hotels h ON rh.hotel_id = h.id
        WHERE rh.utilisateur_id = $1 AND rh.statut != 'annulée'
        ORDER BY rh.date_arrivee DESC
      `, [utilisateurId]);
      res.status(200).json(result.rows);
    } catch (err) {
      res.status(500).json({ erreur: "Erreur lors de la récupération des réservations utilisateur." });
    }
  },
  // Rechercher des hôtels disponibles selon la ville et les dates
  rechercherHotelsDisponibles: async (req, res) => {
    const { ville, date_arrivee, date_depart } = req.query;

    if (!ville || !date_arrivee || !date_depart) {
      return res.status(400).json({ erreur: "Les champs 'ville', 'date_arrivee' et 'date_depart' sont requis." });
    }

    try {
      const result = await db.query(`
        SELECT h.*
        FROM hotels h
        JOIN villes v ON h.ville_id = v.id
        WHERE LOWER(v.nom) = LOWER($1)
        AND h.id NOT IN (
          SELECT hotel_id
          FROM reservations_hotel
          WHERE date_arrivee < $3 AND date_depart > $2
        )
      `, [ville, date_arrivee, date_depart]);

      res.status(200).json(result.rows);
    } catch (err) {
      console.error("❌ Erreur lors de la recherche d'hôtels disponibles :", err);
      res.status(500).json({ erreur: "Erreur lors de la recherche des hôtels disponibles." });
    }
  }
};





module.exports = hotelController;
