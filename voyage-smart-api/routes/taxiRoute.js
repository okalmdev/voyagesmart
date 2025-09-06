// routes/taxiRoutes.js
const express = require('express');
const router = express.Router();
const taxiController = require('../controllers/taxiController');

// Middleware (optionnel) : ex. pour authentification ou vérif rôle
// const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');

/**
 * @route   GET /api/taxis
 * @desc    Récupérer tous les taxis
 * @access  Public
 */
router.get('/', taxiController.getAllTaxis);

/**
 * @route   GET /api/taxis/disponibles/utilisateur/:userId
 * @desc    Récupérer les taxis disponibles pour un utilisateur (basé sur sa réservation bus)
 * @access  Utilisateur connecté
 */
router.get('/disponibles/utilisateur/:userId', taxiController.getAvailableTaxisByUser);

/**
 * @route   POST /api/taxis/reserver
 * @desc    Réserver un taxi
 * @access  Utilisateur connecté
 */
router.post('/reserver', taxiController.reserveTaxi);

/**
 * @route   GET /api/taxis/reservations/admin
 * @desc    Récupérer toutes les réservations (admin uniquement)
 * @access  Admin
 */
// router.get('/reservations/admin', verifyToken, isAdmin, taxiController.getAllReservations);
router.get('/reservations/admin', taxiController.getAllReservations);

/**
 * @route   GET /api/taxis/reservations/utilisateur/:userId
 * @desc    Récupérer les réservations d’un utilisateur
 * @access  Utilisateur connecté
 */
router.get('/reservations/utilisateur/:userId', taxiController.getReservationsByUser);

/**
 * @route   PATCH /api/taxis/annuler/:reservationId
 * @desc    Annuler une réservation
 * @access  Utilisateur connecté
 */
router.patch('/annuler/:reservationId', taxiController.cancelReservation);

module.exports = router;
