const db = require('../db');

// Récupérer tous les taxis
exports.getAllTaxis = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM taxis');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des taxis:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer les taxis disponibles en fonction d'un utilisateur (via sa réservation de bus)
exports.getAvailableTaxisByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    // Exemple simple basé sur la logique: l’utilisateur a une réservation de bus pour aujourd’hui
    const reservations = await db.query(
      `SELECT * FROM reservations_bus WHERE utilisateur_id = $1 AND date_depart = CURRENT_DATE`,
      [userId]
    );

    if (reservations.rows.length === 0) {
      return res.status(404).json({ message: 'Aucune réservation de bus trouvée pour aujourd’hui.' });
    }

    const taxisDisponibles = await db.query(
      `SELECT * FROM taxis WHERE disponible = true`
    );

    res.status(200).json(taxisDisponibles.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des taxis disponibles:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Réserver un taxi
exports.reserveTaxi = async (req, res) => {
  const { utilisateur_id, taxi_id, lieu_depart, destination, heure } = req.body;

  try {
    const insertion = await db.query(
      `INSERT INTO reservations_taxi (utilisateur_id, taxi_id, lieu_depart, destination, heure, statut)
       VALUES ($1, $2, $3, $4, $5, 'confirmée') RETURNING *`,
      [utilisateur_id, taxi_id, lieu_depart, destination, heure]
    );

    // Marquer le taxi comme non disponible
    await db.query(`UPDATE taxis SET disponible = false WHERE id = $1`, [taxi_id]);

    res.status(201).json({ message: 'Réservation confirmée', reservation: insertion.rows[0] });
  } catch (error) {
    console.error('Erreur lors de la réservation du taxi:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer toutes les réservations de taxi (admin)
exports.getAllReservations = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, t.nom AS nom_taxi, u.nom AS nom_utilisateur
      FROM reservations_taxi r
      JOIN taxis t ON r.taxi_id = t.id
      JOIN utilisateurs u ON r.utilisateur_id = u.id
    `);

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer les réservations d’un utilisateur spécifique
exports.getReservationsByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await db.query(
      `SELECT * FROM reservations_taxi WHERE utilisateur_id = $1`,
      [userId]
    );

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations utilisateur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Annuler une réservation
exports.cancelReservation = async (req, res) => {
  const { reservationId } = req.params;

  try {
    // Récupérer la réservation
    const reservation = await db.query(
      `SELECT * FROM reservations_taxi WHERE id = $1`,
      [reservationId]
    );

    if (reservation.rows.length === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée.' });
    }

    const taxiId = reservation.rows[0].taxi_id;

    // Annuler la réservation
    await db.query(
      `UPDATE reservations_taxi SET statut = 'annulée' WHERE id = $1`,
      [reservationId]
    );

    // Remettre le taxi comme disponible
    await db.query(
      `UPDATE taxis SET disponible = true WHERE id = $1`,
      [taxiId]
    );

    res.status(200).json({ message: 'Réservation annulée avec succès.' });
  } catch (error) {
    console.error('Erreur lors de l’annulation:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
