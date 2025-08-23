const express = require('express');
const router = express.Router();
const villesController = require('../controllers/villesController');

// GET toutes les villes
router.get('/', villesController.getAllVilles);

// GET ville par ID
router.get('/:villeId', villesController.getVilleById);

// POST créer une ville
router.post('/', villesController.createVille);

// PUT mettre à jour une ville
router.put('/:villeId', villesController.updateVille);

// DELETE supprimer une ville
router.delete('/:villeId', villesController.deleteVille);

module.exports = router;
