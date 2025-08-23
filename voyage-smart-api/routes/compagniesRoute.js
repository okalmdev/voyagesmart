const express = require('express');
const router = express.Router();
const compagniesController = require('../controllers/compagniesController');


// ✅ Cette route doit venir AVANT /:id
router.get('/ville/:villeId', compagniesController.getCompagniesByVille);

// GET toutes les compagnies ou filtrées par /api/compagnies?villeId=1&nom=Exemple
router.get('/', compagniesController.getAll);

// GET compagnie par ID
router.get('/:id', compagniesController.getById);

// POST créer une compagnie
router.post('/', compagniesController.create);

// PUT mettre à jour une compagnie
router.put('/:id', compagniesController.update);

// DELETE supprimer une compagnie
router.delete('/:id', compagniesController.delete);

module.exports = router;
