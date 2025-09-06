// controllers/taxiController.js
const db = require('../db');

// --------- Récupérer tous les taxis ---------
exports.getAllTaxis = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM taxis ORDER BY id DESC');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur getAllTaxis:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération des taxis' });
  }
};

// --------- Récupérer les taxis disponibles selon un utilisateur ---------
exports.getAvailableTaxisByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const reservations = await db.query(
      `SELECT * FROM reservations_bus 
       WHERE utilisateur_id = $1 AND date_depart = CURRENT_DATE`,
      [userId]
    );

    if (reservations.rows.length === 0) {
      return res.status(404).json({
        message: "Aucune réservation de bus trouvée pour aujourd’hui."
      });
    }

    const taxisDisponibles = await db.query(
      `SELECT * FROM taxis WHERE disponible = true ORDER BY id DESC`
    );

    res.status(200).json(taxisDisponibles.rows);
  } catch (error) {
    console.error('Erreur getAvailableTaxisByUser:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération des taxis disponibles' });
  }
};

// --------- Réserver un taxi ---------
exports.reserveTaxi = async (req, res) => {
  const { utilisateur_id, taxi_id, lieu_depart, destination, heure } = req.body;

  if (!utilisateur_id || !taxi_id || !lieu_depart || !destination || !heure) {
    return res.status(400).json({ message: 'Champs obligatoires manquants.' });
  }

  try {
    const taxi = await db.query(
      `SELECT * FROM taxis WHERE id = $1 AND disponible = true`,
      [taxi_id]
    );

    if (taxi.rows.length === 0) {
      return res.status(400).json({ message: 'Taxi non disponible.' });
    }

    const insertion = await db.query(
      `INSERT INTO reservations_taxi 
        (utilisateur_id, taxi_id, lieu_depart, destination, heure, statut, date_reservation)
       VALUES ($1, $2, $3, $4, $5, 'confirmée', CURRENT_DATE) RETURNING *`,
      [utilisateur_id, taxi_id, lieu_depart, destination, heure]
    );

    await db.query(`UPDATE taxis SET disponible = false WHERE id = $1`, [taxi_id]);

    res.status(201).json({
      message: 'Réservation confirmée',
      reservation: insertion.rows[0]
    });
  } catch (error) {
    console.error('Erreur reserveTaxi:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de la réservation du taxi' });
  }
};

// --------- Récupérer toutes les réservations (admin) ---------
exports.getAllReservations = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, t.nom AS nom_taxi, u.nom AS nom_utilisateur
      FROM reservations_taxi r
      JOIN taxis t ON r.taxi_id = t.id
      JOIN utilisateurs u ON r.utilisateur_id = u.id
      ORDER BY r.id DESC
    `);

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur getAllReservations:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération des réservations' });
  }
};

// --------- Récupérer les réservations d’un utilisateur ---------
exports.getReservationsByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await db.query(
      `SELECT r.*, t.nom AS nom_taxi 
       FROM reservations_taxi r 
       JOIN taxis t ON r.taxi_id = t.id
       WHERE r.utilisateur_id = $1
       ORDER BY r.id DESC`,
      [userId]
    );

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur getReservationsByUser:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération des réservations utilisateur' });
  }
};

// --------- Annuler une réservation ---------
exports.cancelReservation = async (req, res) => {
  const { reservationId } = req.params;

  try {
    const reservation = await db.query(
      `SELECT * FROM reservations_taxi WHERE id = $1`,
      [reservationId]
    );

    if (reservation.rows.length === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée.' });
    }

    if (reservation.rows[0].statut === 'annulée') {
      return res.status(400).json({ message: 'Cette réservation est déjà annulée.' });
    }

    const taxiId = reservation.rows[0].taxi_id;

    await db.query(
      `UPDATE reservations_taxi SET statut = 'annulée' WHERE id = $1`,
      [reservationId]
    );

    await db.query(
      `UPDATE taxis SET disponible = true WHERE id = $1`,
      [taxiId]
    );

    res.status(200).json({ message: 'Réservation annulée avec succès.' });
  } catch (error) {
    console.error('Erreur cancelReservation:', error.message);
    res.status(500).json({ message: 'Erreur serveur lors de l’annulation' });
  }
};
