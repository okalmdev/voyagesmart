import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_model.dart';
import '../models/bus_trip.dart';
import '../models/taxi_model.dart';

/// 🌍 Service centralisé pour gérer toutes les requêtes API de l'application.
/// Contient l'authentification, la gestion des hôtels, bus et taxis.
class ApiService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';

  // ================= AUTH =================

  /// 🔑 Connexion utilisateur
  /// - [email] : email de l'utilisateur
  /// - [password] : mot de passe
  /// Retourne : un Map avec les infos utilisateur et token si succès
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
      throw Exception('❌ Erreur de connexion');
    }
  }

  // ================= HOTELS =================

  /// 🏨 Récupérer tous les hôtels (sans filtre)
  static Future<List<Hotel>> getAllHotels() async {
    final response = await http.get(Uri.parse('$baseUrl/hotels'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement de tous les hôtels");
    }
  }

  /// 🔍 Recherche d'hôtels par ville et dates
  /// - [ville] : ville recherchée
  /// - [dateArrivee] : date d'arrivée
  /// - [dateDepart] : date de départ
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
      throw Exception("❌ Erreur lors de la recherche d'hôtels à $ville");
    }
  }

  /// 🏨 Hôtels locaux uniquement (par ville, sans date)
  static Future<List<Hotel>> getLocalHotelsByVille(String ville) async {
    final url =
    Uri.parse('$baseUrl/hotels/par-ville?ville=${Uri.encodeComponent(ville)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des hôtels locaux à $ville");
    }
  }

  // ================= BUS =================

  /// 🚌 Récupérer tous les trajets de bus
  static Future<List<BusTrip>> getBusTrips() async {
    final response = await http.get(Uri.parse('$baseUrl/voyages'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des trajets de bus");
    }
  }

  /// 🚌 Récupérer tous les trajets depuis une ville donnée
  static Future<List<BusTrip>> getLocalBusTripsByLocation(String ville) async {
    final response = await http.get(
      Uri.parse('$baseUrl/departs/${Uri.encodeComponent(ville)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des trajets pour $ville");
    }
  }

  /// 🔍 Recherche de trajets de bus par critères
  /// - [villeDepart] : ville de départ
  /// - [villeArrivee] : ville d’arrivée
  /// - [dateDepart] : date du trajet
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

      final response = await http.post(
        Uri.parse('$baseUrl/bus/recherche'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // ✅ Réponse vide → aucun trajet trouvé
          return [];
        }

        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey("message")) {
          // ✅ Réponse informative du serveur (pas de résultats)
          return [];
        } else if (decoded is List) {
          // ✅ Liste de trajets
          return decoded.map((json) => BusTrip.fromJson(json)).toList();
        } else if (decoded is Map && decoded.containsKey("data")) {
          // ✅ Objet contenant "data"
          final List<dynamic> jsonList = decoded["data"];
          return jsonList.map((json) => BusTrip.fromJson(json)).toList();
        } else {
          throw Exception("⚠️ Format inattendu: $decoded");
        }
      } else {
        throw Exception("❌ Erreur API ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("💥 Exception dans searchBusTrips: $e");
    }
  }

  /// 📅 Récupérer les programmes du jour
  static Future<List<BusTrip>> getDailyBusPrograms() async {
    final response = await http.get(Uri.parse('$baseUrl/programmes-du-jour'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des programmes du jour");
    }
  }

  /// 🚌 Récupérer un programme de bus par son ID
  static Future<BusTrip> getBusProgramById(int busId) async {
    final response = await http.get(Uri.parse('$baseUrl/programme/$busId'));
    if (response.statusCode == 200) {
      return BusTrip.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("❌ Erreur lors du chargement du programme du bus");
    }
  }

  /// 🏢 Récupérer le programme d’une compagnie
  static Future<List<BusTrip>> getCompanyBusProgram(String nomCompagnie) async {
    final response = await http.get(
      Uri.parse('$baseUrl/compagnie/${Uri.encodeComponent(nomCompagnie)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BusTrip.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement du programme de la compagnie");
    }
  }

  /// 🚌 Réserver un trajet de bus
  static Future<Map<String, dynamic>> reserveBus({
    required int utilisateurId,
    required int voyageId,
    required String dateReservation,
    required List<String> numeroPlace, // <-- changer ici
    required double prix,
  }) async {
    final url = Uri.parse('$baseUrl/bus/reserver');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "utilisateur_id": utilisateurId,
        "voyage_id": voyageId,
        "date_reservation": dateReservation,
        "numero_place": numeroPlace, // envoie la liste
        "prix": prix,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Erreur réservation: ${response.statusCode} - ${response.body}");
    }
  }



  /// ❌ Annuler une réservation de bus
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
      throw Exception('❌ Erreur annulation: $e');
    }
  }

  /// ✅ Finaliser une réservation (après paiement)
  static Future<void> finishBusReservation(int reservationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/terminer/$reservationId'),
    );
    if (response.statusCode != 200) {
      throw Exception("❌ Erreur lors de la finalisation de la réservation");
    }
  }

  // ================= TAXIS =================

  /// 🚕 Récupérer tous les taxis
  static Future<List<Taxi>> getAllTaxis() async {
    final response = await http.get(Uri.parse('$baseUrl/taxis'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des taxis");
    }
  }

  /// 🚕 Récupérer les taxis disponibles pour un utilisateur
  static Future<List<Taxi>> getAvailableTaxisByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taxis/disponibles/utilisateur/$userId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // Aucun taxi trouvé
    } else {
      throw Exception("❌ Erreur lors du chargement des taxis disponibles");
    }
  }

  /// 🚕 Récupérer les taxis locaux dans une ville donnée
  static Future<List<Taxi>> getLocalTaxisByLocation(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taxis/local?city=${Uri.encodeComponent(city)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Taxi.fromJson(json)).toList();
    } else {
      throw Exception("❌ Erreur lors du chargement des taxis locaux pour $city");
    }
  }

  /// 🚕 Réserver un taxi
  /// - [userId] : identifiant utilisateur
  /// - [taxiId] : identifiant taxi
  /// - [lieuDepart] : lieu de départ
  /// - [lieuArrivee] : destination
  /// - [heureDepart] : heure prévue
  static Future<Map<String, dynamic>> reserveTaxi({
    required String userId,
    required String taxiId,
    required String lieuDepart,
    required String lieuArrivee,
    required String heureDepart,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxis/reserver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'utilisateur_id': userId,
        'taxi_id': taxiId,
        'lieu_depart': lieuDepart,
        'destination': lieuArrivee,
        'heure': heureDepart,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Erreur réservation taxi : ${response.body}');
    }
  }
}
