import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/taxi_model.dart';
import '../services/api_service.dart';
import 'taxi_reservation_screen.dart';

class TaxiScreen extends StatefulWidget {
  final String userId; // 🔑 Identifiant utilisateur
  const TaxiScreen({super.key, required this.userId});

  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  List<Taxi> taxis = []; // 🚖 Liste des taxis récupérés depuis l’API
  bool isLoading = true; // ⏳ Indicateur de chargement
  Position? userPosition; // 📍 Position GPS actuelle de l’utilisateur

  @override
  void initState() {
    super.initState();
    _loadTaxis(); // ⬅️ Charger les taxis dès l’ouverture de la page
  }

  /// 🔄 Charge les taxis disponibles pour l’utilisateur connecté
  Future<void> _loadTaxis() async {
    try {
      // 📍 Récupère la position actuelle de l’utilisateur
      final pos = await Geolocator.getCurrentPosition();

      // 🚖 Récupère les taxis disponibles via l’API
      final data = await ApiService.getAvailableTaxisByUser(widget.userId);

      // ✅ Vérifie que le widget est toujours monté avant de mettre à jour l'état
      if (!mounted) return;

      // 🔄 Met à jour l’état du widget avec les données reçues
      setState(() {
        userPosition = pos;
        taxis = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      // ⚠️ Affiche une notification en cas d’erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taxis disponibles"),
        backgroundColor: const Color(0xFF4CAF50), // ✅ Couleur verte uniforme
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // ⏳ En cours de chargement
          : taxis.isEmpty
          ? const Center(child: Text("Aucun taxi disponible")) // 🚫 Pas de taxis
          : ListView.builder(
        itemCount: taxis.length,
        itemBuilder: (context, index) {
          final taxi = taxis[index];
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4, // 🌟 Shadow pour un look moderne
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: taxi.image != null
                    ? NetworkImage(taxi.image!) // 📷 Photo du chauffeur/taxi
                    : const AssetImage('assets/taxi.png') as ImageProvider,
              ),
              title: Text(taxi.chauffeur), // 👤 Nom du chauffeur
              subtitle: Text("Ville: ${taxi.ville}"), // 🏙 Ville
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Réserver"),
                onPressed: () {
                  // 🔀 Redirection vers la page de réservation du taxi
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaxiReservationScreen(
                        userId: widget.userId,
                        taxi: taxi,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
