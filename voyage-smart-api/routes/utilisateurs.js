const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController'); // adapte le nom du fichier

// Routes CRUD utilisateurs
router.get('/', userController.getAllUsers);
router.get('/:userId', userController.getUserById);
router.post('/', userController.createUser);
router.put('/:userId', userController.updateUser);
router.delete('/:userId', userController.deleteUser);

module.exports = router;
