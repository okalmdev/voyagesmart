// Identique à ton fichier, mais je structure la logique de navigation plus clairement, sans changer aucun style.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/bus_trip.dart';
import '../services/api_service.dart';
import 'bus_list_screen.dart';
import 'hotel_list_screen.dart';
import 'taxi_screen.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String currentCity = "Bamako";
  bool isLoading = true;

  final List<Map<String, String>> _partners = [
    {'name': 'DIARRA TRANSPORT', 'image': 'assets/images/diarra_logo.jpg'},
    {'name': 'NOUR TRANSPORT', 'image': 'assets/images/nour_logo.jpg'},
    {'name': 'AIR NIONO TRANSPORT', 'image': 'assets/images/air_niono_logo.jpg'},
    {'name': 'SONEF TRNSPORT', 'image': 'assets/images/sonef_logo.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentCity();
  }

  Future<void> _getCurrentCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() => isLoading = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          currentCity = placemarks.first.locality ?? "Bamako";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur localisation : $e");
      setState(() => isLoading = false);
    }
  }

  void _onSearch(String query) {
    print("Recherche utilisateur : $query");
    // Implémenter la logique de recherche ici si besoin
  }

  void _navigateTo(String route) async {
    if (isLoading) return;

    switch (route) {
      case '/bus':
        try {
          // 📍 Récupérer la ville actuelle (par GPS ou service interne)
          final String currentCity = await LocationService.getCurrentCity();

          // 🚍 Récupérer les trajets filtrés par ville
          final List<BusTrip> trips =
          await ApiService.getLocalBusTripsByLocation(currentCity);

          if (!mounted) return;

          // 🧭 Navigation vers l'écran de liste de bus
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusListScreen(
                trips: trips,
                currentCity: currentCity, // Optionnel si l'écran a besoin
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $error')),
          );
        }
        break;


      case '/hotel':
        final today = DateTime.now();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelListScreen(
              ville: currentCity,
              dateArrivee: today,
              dateDepart: today.add(const Duration(days: 1)),
              localOnly: true,
            ),
          ),
        );

        break;

      case '/taxi':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaxiScreen(
              localOnly: true,
              location: currentCity,
            ),
          ),
        );
        break;

      case '/profile':
        print("Naviguer vers Profil (à implémenter)");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Image.asset('assets/images/logo_vsmart.png', fit: BoxFit.contain),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bonjour, ${widget.userName} 👋",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50))),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Rechercher par ville, compagnie ou hôtel",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                filled: true,
                fillColor: Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Nos services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard("Bus", Icons.directions_bus, '/bus'),
                  _buildServiceCard("Taxi", Icons.local_taxi, '/taxi'),
                  _buildServiceCard("Hôtel", Icons.hotel, '/hotel'),
                  _buildServiceCard("Profil", Icons.person, '/profile'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Nos partenaires",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _partners.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final partner = _partners[index];
                  return GestureDetector(
                    onTap: () => print("Partenaire sélectionné : ${partner['name']}"),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(partner['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          partner['name']!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
