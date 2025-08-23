import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  /// Demande la permission et récupère la position actuelle
  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('La localisation est désactivée');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission refusée définitivement. Activez-la dans les paramètres.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Récupère le nom de la ville via OpenStreetMap Nominatim
  static Future<String> getCurrentCity() async {
    try {
      Position position = await _getCurrentPosition();

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'VoyageSmart/1.0 (contact@example.com)' // Obligatoire pour Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? city = data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['state'];

        if (city != null && city.isNotEmpty) {
          return city;
        } else {
          throw Exception('Impossible de déterminer la ville');
        }
      } else {
        throw Exception('Erreur API Nominatim : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur localisation : $e');
    }
  }
}
