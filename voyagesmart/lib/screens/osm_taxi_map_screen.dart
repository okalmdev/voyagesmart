import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class OsmTaxiMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> taxis;

  const OsmTaxiMapScreen({Key? key, required this.taxis}) : super(key: key);

  @override
  State<OsmTaxiMapScreen> createState() => _OsmTaxiMapScreenState();
}

class _OsmTaxiMapScreenState extends State<OsmTaxiMapScreen> {
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final hasPermission = await Geolocator.checkPermission();
    if (hasPermission == LocationPermission.denied ||
        hasPermission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userPosition = pos;
    });
  }

  double _calculateDistance(double lat1, double lng1) {
    if (userPosition == null) return 0;
    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat1,
      lng1,
    );
    return distance / 1000; // km
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  void _showDriverPopup(BuildContext context, Map<String, dynamic> taxi) {
    final distanceKm = _calculateDistance(taxi['lat'], taxi['lng']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Détails du Chauffeur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(taxi['image'] ?? ''),
              radius: 35,
            ),
            const SizedBox(height: 12),
            Text("👤 ${taxi['driver_name']}"),
            Text("📍 ${taxi['city']}"),
            Text("📞 ${taxi['phone']}"),
            if (distanceKm > 0)
              Text("📏 Distance : ${distanceKm.toStringAsFixed(2)} km"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchCaller(taxi['phone']);
            },
            child: const Text("Appeler"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> taxis = [...widget.taxis];

    if (userPosition != null) {
      taxis.sort((a, b) {
        final distA = _calculateDistance(a['lat'], a['lng']);
        final distB = _calculateDistance(b['lat'], b['lng']);
        return distA.compareTo(distB);
      });
    }

    final LatLng defaultCenter = userPosition != null
        ? LatLng(userPosition!.latitude, userPosition!.longitude)
        : (taxis.isNotEmpty
        ? LatLng(taxis.first['lat'], taxis.first['lng'])
        : LatLng(12.6392, -8.0029)); // par défaut : Bamako

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Taxis"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: defaultCenter,
          initialZoom: 13.0,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.voyage.smart',
          ),
          MarkerLayer(
            markers: taxis
                .where((taxi) => taxi['disponible'] == true)
                .map((taxi) => Marker(
              point: LatLng(taxi['lat'], taxi['lng']),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDriverPopup(context, taxi),
                child: const Icon(Icons.local_taxi,
                    color: Colors.green, size: 36),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
