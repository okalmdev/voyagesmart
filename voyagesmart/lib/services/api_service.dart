import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_model.dart';
import '../models/bus_trip.dart';
import '../models/taxi_model.dart'; //

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur de connexion');
    }
  }

  // ---------- HÔTELS ----------

  /// 🔁 Tous les hôtels (sans filtre)
  static Future<List<Hotel>> getAllHotels() async {
    final response = await http.get(Uri.parse('$baseUrl/hotels'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement de tous les hôtels");
    }
  }

  /// 🔍 Recherche d'hôtels par ville et dates
  static Future<List<Hotel>> getHotelsByVilleEtDates({
    required String ville,
    required String dateArrivee,
    required String dateDepart,
  }) async {
    final url = Uri.parse(
      '$baseUrl/hotels/recherche?ville=${Uri.encodeComponent(ville)}'
          '&date_arrivee=$dateArrivee&date_depart=$dateDepart',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la recherche d'hôtels à $ville");
    }
  }

  /// 🏨 Hôtels locaux uniquement (par ville, sans date)
  static Future<List<Hotel>> getLocalHotelsByVille(String ville) async {
    final url = Uri.parse('$baseUrl/hotels/par-ville?ville=${Uri.encodeComponent(ville)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des hôtels locaux à $ville");
    }
  }


  // ---------- BUS ----------
  // ---------- BUS ----------
  static Future<List<BusTrip>> getBusTrips() async {
    // Récupère tous les voyages
    final response = await http.get(Uri.parse('$baseUrl/voyages'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des trajets de bus");
    }
  }

  static Future<List<BusTrip>> getLocalBusTripsByLocation(String ville) async {
    // Récupère tous les départs depuis une ville donnée (pour le bouton switch géoloc)
    final response = await http.get(
      Uri.parse('$baseUrl/departs/${Uri.encodeComponent(ville)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des trajets pour $ville");
    }
  }

  static Future<List<BusTrip>> searchBusTrips({
    required String villeDepart,
    required String villeArrivee,
    required String dateDepart,
  }) async {
    try {
      final body = {
        "ville_depart": villeDepart,
        "ville_arrivee": villeArrivee,
        "date_depart": dateDepart,
      };

      print("📤 Body envoyé: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('$baseUrl/bus/recherche'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Réponse brute: ${response.body}");

      if (response.statusCode == 200) {
        // ✅ Nouvelle vérification : si le corps est vide, on retourne une liste vide
        if (response.body.isEmpty) {
          print("⚠️ Réponse vide du serveur, aucun résultat.");
          return [];
        }

        final decoded = jsonDecode(response.body);

        // ✅ Gère le cas où le serveur renvoie un message au lieu de données
        if (decoded is Map && decoded.containsKey("message")) {
          print("ℹ️ Message du serveur: ${decoded['message']}");
          return [];
        }
        // Gère le cas où la réponse est une liste
        else if (decoded is List) {
          return decoded.map((json) => BusTrip.fromJson(json)).toList();
        }
        // Gère le cas où la réponse est un objet avec une clé "data"
        else if (decoded is Map && decoded.containsKey("data")) {
          final List<dynamic> jsonList = decoded["data"];
          return jsonList.map((json) => BusTrip.fromJson(json)).toList();
        }
        // Cas non géré, on lève une exception pour les autres formats
        else {
          throw Exception("⚠️ Format inattendu: $decoded");
        }
      } else {
        throw Exception("❌ Erreur API ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("💥 Exception dans searchBusTrips: $e");
    }
  }


  static Future<List<BusTrip>> getDailyBusPrograms() async {
    // Programmes du jour
    final response = await http.get(Uri.parse('$baseUrl/programmes-du-jour'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des programmes du jour");
    }
  }

  static Future<BusTrip> getBusProgramById(int busId) async {
    // Programme d'un bus par ID
    final response = await http.get(Uri.parse('$baseUrl/programme/$busId'));
    if (response.statusCode == 200) {
      return BusTrip.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur lors du chargement du programme du bus");
    }
  }

  static Future<List<BusTrip>> getCompanyBusProgram(String nomCompagnie) async {
    // Programme par compagnie
    final response = await http.get(
      Uri.parse('$baseUrl/compagnie/${Uri.encodeComponent(nomCompagnie)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement du programme de la compagnie");
    }
  }
  // Accès au 'baseUrl' et à l'userId de l'utilisateur.

  static Future<List<String>> reserveBus({
    required String tripId,
    required List<int> seats,
    required String userId,
    required double pricePerSeat,
  }) async {
    final List<String> reservationIds = [];

    try {
      for (int seatNumber in seats) {
        final url = Uri.parse('$baseUrl/reserver');
        final headers = {'Content-Type': 'application/json'};
        final body = jsonEncode({
          "voyage_id": tripId,
          "numero_place": seatNumber.toString(),
          "utilisateur_id": userId,
          "date_reservation": DateTime.now().toIso8601String().split('T')[0],
          "prix": pricePerSeat,
        });

        final response = await http.post(url, headers: headers, body: body);

        // ✅ VÉRIFIER LE CONTENU DE LA RÉPONSE AVANT JSON DECODE
        if (response.statusCode == 201) {
          if (response.body.isEmpty) {
            throw Exception("Réponse vide du serveur pour le siège $seatNumber");
          }

          try {
            final data = jsonDecode(response.body);
            if (data['reservation_id'] != null) {
              reservationIds.add(data['reservation_id'].toString());
            } else {
              throw Exception("ID de réservation manquant dans la réponse");
            }
          } catch (e) {
            print("Réponse brute du serveur: ${response.body}");
            throw Exception("Format JSON invalide pour le siège $seatNumber: $e");
          }
        } else {
          // Gestion d'erreur avec vérification JSON
          String errorMessage = "Erreur siège $seatNumber";

          if (response.body.isNotEmpty) {
            try {
              final errorData = jsonDecode(response.body);
              errorMessage = errorData['erreur'] ?? errorMessage;
            } catch (e) {
              errorMessage = "Erreur serveur (statut: ${response.statusCode})";
            }
          }

          // Annuler les réservations déjà faites
          for (String id in reservationIds) {
            try {
              await cancelReservation(id);
            } catch (e) {
              print("Erreur annulation $id: $e");
            }
          }

          throw Exception(errorMessage);
        }
      }

      return reservationIds;
    } catch (error) {
      throw Exception("Échec réservation: $error");
    }
  }

// Méthode pour annuler une réservation
  static Future<void> cancelReservation(String reservationId) async {
    try {
      final url = Uri.parse('$baseUrl/annuler/$reservationId');
      final response = await http.put(url);

      if (response.statusCode != 200) {
        String errorMsg = "Échec annulation";
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMsg = errorData['erreur'] ?? errorMsg;
          } catch (e) {
            errorMsg = "Erreur serveur (statut: ${response.statusCode})";
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Erreur annulation: $e');
    }
  }
  static Future<void> finishBusReservation(int reservationId) async {
    // Terminer une réservation
    final response = await http.patch(
      Uri.parse('$baseUrl/terminer/$reservationId'),
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la finalisation de la réservation");
    }
  }


  // ---------- TAXI ----------
  static Future<List<Taxi>> getAvailableTaxis() async {
    final response = await http.get(Uri.parse('$baseUrl/taxi'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des taxis disponibles");
    }
  }

  static Future<List<Taxi>> getLocalTaxisByLocation(String location) async {
    final response = await http.get(Uri.parse('$baseUrl/taxi/local?city=${Uri.encodeComponent(location)}'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des taxis locaux pour $location");
    }
  }

  // ---------- RESERVER TAXI ----------
  static Future<void> reserveTaxi({
    required String userId,
    required String taxiId,
    required String dateReservation,
    required String heureDepart,
    required String lieuDepart,
    required String lieuArrivee,
    required int prix,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxi/reserve'),  // adapte cette URL selon ton backend
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'taxi_id': taxiId,
        'date_reservation': dateReservation,
        'heure_depart': heureDepart,
        'lieu_depart': lieuDepart,
        'lieu_arrivee': lieuArrivee,
        'prix': prix,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la réservation du taxi');
    }
  }
}
