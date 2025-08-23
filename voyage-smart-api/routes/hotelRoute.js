const express = require("express");
const router = express.Router();
const hotelController = require("../controllers/hotelController");

////////////////////////
// HÔTELS
////////////////////////

// 🔍 Récupérer tous les hôtels
router.get("/", hotelController.getAllHotels);


// Réchercher les hotels disponibles
router.get("/recherche", hotelController.rechercherHotelsDisponibles);

// 🔍 Récupérer les hôtels par ville ?villeId=1
router.get("/par-ville", hotelController.getHotelsByCity);

// ➕ Ajouter un hôtel
router.post("/ajouter", hotelController.addHotel);

// ✏️ Modifier un hôtel
router.put("/modifier/:id", hotelController.updateHotel);

// ❌ Supprimer un hôtel
router.delete("/supprimer/:id", hotelController.deleteHotel);

//hotels recommendes 

router.get('/recommandes', hotelController.getRecommendedHotels);

////////////////////////
// RÉSERVATIONS HÔTEL
////////////////////////

// 🛎️ Réserver un hôtel
router.post("/reserver", hotelController.reserveHotel);

// 📄 Récupérer toutes les réservations (admin)
router.get("/reservations", hotelController.getAllReservations);

// 👤 Récupérer les réservations d’un utilisateur
router.get("/utilisateur/:utilisateurId", hotelController.getReservationsByUser);

// ❌ Annuler une réservation
router.patch("/annuler/:reservationId", hotelController.cancelReservation);

// ✅ Terminer une réservation
router.patch("/terminer/:reservationId", hotelController.terminerReservation);

// ✏️ Modifier une réservation
router.put("/modifier-reservation/:reservationId", hotelController.updateReservation);

module.exports = router;
