const express = require('express');
const router = express.Router();
const taxiController = require('../controllers/taxiController');

// GET tous les taxis
router.get('/', taxiController.getAllTaxis);

// GET taxis disponibles pour un utilisateur (via sa réservation bus)
router.get('/disponibles/utilisateur/:userId', taxiController.getAvailableTaxisByUser);

// POST réserver un taxi
router.post('/reserver', taxiController.reserveTaxi);

// GET toutes les réservations (admin uniquement)
router.get('/reservations/admin', taxiController.getAllReservations);

// GET réservations d’un utilisateur
router.get('/reservations/utilisateur/:userId', taxiController.getReservationsByUser);

// PATCH annuler une réservation
router.patch('/annuler/:reservationId', taxiController.cancelReservation);

module.exports = router;
