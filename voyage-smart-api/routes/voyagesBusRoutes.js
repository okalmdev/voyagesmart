const express = require('express');
const router = express.Router();
const voyagesBusController = require('../controllers/voyagesBusController');

// GET tous les voyages
router.get('/', voyagesBusController.getAllBusTrips);

// POST un nouveau voyage
router.post('/', voyagesBusController.createBusTrip);

// PUT (modifier) un voyage
router.put('/:id', voyagesBusController.updateBusTrip);

// DELETE un voyage
router.delete('/:id', voyagesBusController.deleteBusTrip);

module.exports = router;
