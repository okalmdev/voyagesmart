// middlewares/authMiddleware.js
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'secret123';
const isDevelopment = process.env.NODE_ENV === 'development';

function authenticateToken(req, res, next) {
  // Bypass en dev seulement
  if (isDevelopment && process.env.AUTH_BYPASS === 'true') {
    console.warn('[DEV] Bypass d\'authentification activé');
    console.log('📦 Body reçu (mode bypass):', req.body);

    req.user = {
      id: 1,
      email: 'fahaddoul@youssoufa.com',
      role: 'admin'
    };
    return next();
  }

  // Récupérer le token depuis le header Authorization
  const authHeader = req.headers['authorization'];
  const token = authHeader?.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (!token) {
    return res.status(401).json({ error: 'Token manquant' });
  }

  jwt.verify(token, SECRET, (err, user) => {
    if (err) {
      console.error('Erreur de vérification du token:', err);
      return res.status(403).json({ error: 'Token invalide' });
    }

    req.user = user;
    console.log('📦 Body reçu (token valide):', req.body);

    next();
  });
}

// Sécurité : interdiction de bypass en prod
if (process.env.NODE_ENV === 'production' && process.env.AUTH_BYPASS === 'true') {
  console.error('⚠️ ATTENTION: Bypass d\'auth activé en production!');
  process.exit(1);
}

module.exports = authenticateToken;
