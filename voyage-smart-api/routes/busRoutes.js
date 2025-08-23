const express = require('express');
const router = express.Router();
const busController = require('../controllers/busController');

// Récupérer tous les voyages de bus
router.get('/voyages', busController.getAllTrips);

// Réserver un voyage de bus
router.post('/reserver', busController.reserveBus);

// Annuler une réservation de bus
router.patch('/annuler/:reservationId', busController.cancelReservation);

// Marquer une réservation comme terminée
router.patch('/terminer/:reservationId', busController.terminerReservation);

// Récupérer les programmes de bus du jour
router.get('/programmes-du-jour', busController.getDailyPrograms);

// Récupérer un programme de bus par son ID
router.get('/programme/:busId', busController.getBusProgramById);

// Récupérer le programme d’une compagnie par son nom
router.get('/compagnie/:nomCompagnie', busController.getCompanyProgram);

// Rechercher des voyages selon critères (départ, arrivée, date)
router.post('/recherche', busController.searchTrips);

// Récupérer tous les départs depuis une ville donnée
router.get('/departs/:ville', busController.getDeparturesFromCity);

module.exports = router;