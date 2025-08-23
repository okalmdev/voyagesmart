// app.js
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Import routes
const routesAuth = require('./routes/auth'); // à créer si besoin
const routesHotels = require('./routes/hotelRoute');
const routesVilles = require('./routes/villeRoute');
const routesUtilisateurs = require('./routes/utilisateurs');
const routesTaxis = require('./routes/taxiRoute');
const routesCompagnies = require('./routes/compagniesRoute');
const voyagesBusRoutes = require('./routes/voyagesBusRoutes');
const busRoutes = require('./routes/busRoutes');
const verifierToken = require('./middlewares/authMiddleware');



// Routes publiques
app.use('/api/auth', routesAuth);

// Middleware d'authentification pour protéger les routes suivantes
app.use(verifierToken);
 
// Routes protégées
app.use('/api/hotels', routesHotels);
app.use('/api/villes', routesVilles);
app.use('/api/utilisateurs', routesUtilisateurs);
app.use('/api/taxis', routesTaxis);
app.use('/api/compagnies', routesCompagnies);
app.use('/api/voyages', voyagesBusRoutes);  // Pour admin
app.use('/api/bus', busRoutes);             // Pour utilisateur
// Route spéciale pour récupérer les infos utilisateur connecté
const pool = require('./db');
app.get('/api/utilisateurs/moi', async (req, res) => {
  try {
    const utilisateurId = req.user.userId;
    const resultat = await pool.query(
      'SELECT id, nom, email FROM utilisateurs WHERE id = $1',
      [utilisateurId]
    );
    res.json(resultat.rows[0]);
  } catch (err) {
    console.error('Erreur récupération utilisateur:', err);
    res.status(500).json({ erreur: 'Erreur lors de la récupération de vos informations.' });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`✅ API démarrée sur http://localhost:${PORT}`);
});
