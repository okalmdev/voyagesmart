import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/bus_trip.dart';
import '../services/api_service.dart';
import 'bus_list_screen.dart';
import 'hotel_list_screen.dart';
import 'taxi_screen.dart';
import 'contact_screen.dart';
import 'partenaire/partner_detail_screen.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool showSearchField = false;
  String currentCity = "Bamako";
  bool isLoading = true;

  final List<Map<String, String>> _partners = [
    {
      'name': 'DIARRA TRANSPORT',
      'image': 'assets/images/diarra_logo.jpg',
      'category': 'Transport'
    },
    {
      'name': 'NOUR TRANSPORT',
      'image': 'assets/images/nour_logo.jpg',
      'category': 'Transport'
    },
    {
      'name': 'AIR NIONO',
      'image': 'assets/images/air_niono_logo.jpg',
      'category': 'Transport'
    },
    {
      'name': 'SONEF HOTEL',
      'image': 'assets/images/sonef_logo.jpg',
      'category': 'Hôtel'
    },
  ];

  String selectedPartnerCategory = 'Tous';

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
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          currentCity = placemarks.first.locality ?? "Bamako";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur localisation : $e");
    }
  }

  void _onSearch(String query) {
    debugPrint("Recherche utilisateur : $query");
  }

  void _navigateTo(String route) async {
    if (isLoading) return;

    switch (route) {
      case '/bus':
        try {
          final String city = await LocationService.getCurrentCity();
          final List<BusTrip> trips =
          await ApiService.getLocalBusTripsByLocation(city);
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusListScreen(trips: trips, currentCity: city),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Erreur : $error')));
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
            builder: (_) => TaxiScreen(userId: '1'),
          ),
        );
        break;

      case '/contact':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactScreen()),
        );
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
        titleSpacing: 0,
        title: Row(
          children: [
            // ✅ Logo Voyage Smart sur fond BLANC circulaire
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                color: Colors.white,            // fond blanc
                shape: BoxShape.circle,         // cercle
              ),
              padding: const EdgeInsets.all(6), // respire autour du logo
              child: Image.asset(
                'assets/images/logo_vsmart.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: showSearchField
                  ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: TextField(
                  key: const ValueKey("searchField"),
                  controller: _searchController,
                  onChanged: _onSearch,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF4CAF50)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
                  : Text(
                "Bonjour, ${widget.userName} 👋",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // texte blanc sur vert
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                showSearchField ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () =>
                  setState(() => showSearchField = !showSearchField),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Catégories de service",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount:
                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _buildServiceCard(
                      "Bus", Icons.directions_bus, '/bus'),
                  _buildServiceCard(
                      "Taxi", Icons.local_taxi, '/taxi'),
                  _buildServiceCard(
                      "Hôtel", Icons.hotel, '/hotel'),
                  _buildServiceCard(
                      "Contact", Icons.support_agent, '/contact'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Section partenaires
            _buildPartnersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String titre, IconData icone, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 48, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                titre,
                style: const TextStyle(
                  color: Colors.white, // blanc sur fond vert
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnersSection() {
    final filteredPartners = _partners
        .where((p) =>
    selectedPartnerCategory == 'Tous' ||
        p['category'] == selectedPartnerCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Partenaires",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedPartnerCategory,
              items: ['Tous', 'Transport', 'Hôtel']
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPartnerCategory = value ?? 'Tous';
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredPartners.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final partner = filteredPartners[index];
              return _PartnerCard(partner: partner);
            },
          ),
        ),
      ],
    );
  }
}

class _PartnerCard extends StatefulWidget {
  final Map<String, String> partner;
  const _PartnerCard({required this.partner});

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerDetailScreen(partner: widget.partner),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(widget.partner['image']!),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              widget.partner['name']!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
