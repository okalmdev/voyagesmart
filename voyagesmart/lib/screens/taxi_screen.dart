import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'taxi_reservation_screen.dart';

class TaxiScreen extends StatefulWidget {
  final String? location;
  final bool? localOnly;

  const TaxiScreen({
    super.key,
    this.location,
    this.localOnly,
  });

  @override
  State<TaxiScreen> createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allTaxis = [
    {
      "id": 1,
      "driver_name": "Moussa Diallo",
      "phone": "73460055",
      "city": "Bamako",
      "lat": 12.6392,
      "lng": -8.0029,
      "disponible": true,
      "image": "https://www.pexels.com/photo/man-in-gray-suit-jacket-sitting-inside-the-car-8425388/"
    },
    {
      "id": 2,
      "driver_name": "Aïssata Konaté",
      "phone": "72383013",
      "city": "Bamako",
      "lat": 12.6328,
      "lng": -7.9961,
      "disponible": true,
      "image": "https://images.pexels.com/photos/9350305/pexels-photo-9350305.jpeg"
    },
    {
      "id": 3,
      "driver_name": "Abdoulaye Coulibaly",
      "phone": "82181021",
      "city": "Bamako",
      "lat": 12.6450,
      "lng": -8.0070,
      "disponible": false,
      "image": "https://www.pexels.com/photo/man-in-white-button-up-shirt-driving-car-4606347/"
    },
  ];

  String searchQuery = '';
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() => userPosition = pos);
    }
  }

  List<Map<String, dynamic>> get filteredTaxis {
    final query = searchQuery.toLowerCase();

    final filtered = allTaxis.where((taxi) {
      final matchesSearch = taxi['driver_name'].toLowerCase().contains(query) ||
          taxi['city'].toLowerCase().contains(query);

      final matchesLocation = widget.location == null ||
          taxi['city'].toLowerCase() == widget.location!.toLowerCase();

      final isDisponible = taxi['disponible'] == true;

      if (widget.localOnly == true) {
        // Si localOnly=true, on filtre aussi par ville (location)
        return isDisponible && matchesSearch && matchesLocation;
      } else {
        // Sinon, juste disponible + recherche
        return isDisponible && matchesSearch;
      }
    });

    if (userPosition == null) return filtered.toList();

    final Distance distance = Distance();
    return filtered
        .map((taxi) {
      final d = distance.as(
        LengthUnit.Kilometer,
        LatLng(userPosition!.latitude, userPosition!.longitude),
        LatLng(taxi['lat'], taxi['lng']),
      );
      return {...taxi, "distance": d};
    })
        .toList()
      ..sort((a, b) => (a['distance']).compareTo(b['distance']));
  }

  void _onTaxiTap(Map<String, dynamic> taxi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaxiReservationScreen(
          taxi: taxi,
          departure: '',
          arrival: '',
          selectedTime: TimeOfDay.now(),
        ),
      ),
    );
  }

  Widget buildTaxiCard(Map<String, dynamic> taxi) {
    final double? distance = taxi['distance'];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(taxi['image']),
          radius: 28,
        ),
        title: Text(
          taxi['driver_name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 ${taxi['city']}"),
            if (distance != null) Text("📏 ${distance.toStringAsFixed(2)} km"),
            Text("💰 Estimé: ${(distance ?? 0) * 200} FCFA"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () async {
            final url = Uri.parse('tel:${taxi['phone']}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Impossible d’ouvrir l’appel")),
              );
            }
          },
        ),
        onTap: () => _onTaxiTap(taxi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taxis disponibles"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                labelText: "Rechercher un taxi ou une ville",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: userPosition == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              children: filteredTaxis.map((taxi) => buildTaxiCard(taxi)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
