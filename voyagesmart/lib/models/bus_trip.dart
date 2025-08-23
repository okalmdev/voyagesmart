import 'package:intl/intl.dart';

class BusTrip {
  final String id;
  final String company;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final bool isAvailable;
  final String? busNumber;

  BusTrip({
    required this.id,
    required this.company,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.isAvailable,
    this.busNumber,
  });

  // --- Getters pour le formatage ---
  String get formattedDepartureTime => DateFormat.Hm().format(departureTime);
  String get formattedArrivalTime => DateFormat.Hm().format(arrivalTime);
  String get formattedDate => DateFormat('dd/MM/yyyy').format(departureTime);

  String get duration {
    final diff = arrivalTime.difference(departureTime);
    return '${diff.inHours}h ${diff.inMinutes.remainder(60)}min';
  }

  // --- JSON parsing ---
  factory BusTrip.fromJson(Map<String, dynamic> json) {
    // 🎉 Version la plus sécurisée de la fonction de parsing
    final String priceString = json['prix']?.toString() ?? '0.0';
    final String availableSeatsString = json['places_restantes']?.toString() ?? '0';
    final String totalSeatsString = json['nombre_places']?.toString() ?? '0';

    return BusTrip(
      id: json['id']?.toString() ?? '',
      busNumber: json['numero_bus'] as String?,
      // Utilisation d'un opérateur null-aware pour éviter les erreurs de type
      company: json['compagnie'] as String? ?? '',
      departureCity: json['ville_depart'] as String? ?? '',
      arrivalCity: json['ville_arrivee'] as String? ?? '',
      // Utilisation de tryParse pour les dates pour gérer les valeurs nulles
      departureTime: DateTime.tryParse(json['heure_depart'] as String? ?? '') ?? DateTime.now(),
      arrivalTime: DateTime.tryParse(json['heure_arrivee'] as String? ?? '') ?? DateTime.now(),
      price: double.tryParse(priceString) ?? 0.0,
      totalSeats: int.tryParse(totalSeatsString) ?? 0,
      availableSeats: int.tryParse(availableSeatsString) ?? 0,
      isAvailable: json['statut'] == 'DISPONIBLE',
    );
  }

  // --- JSON sérialisation (inutile pour le client, mais bonne pratique) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compagnie': company,
      'ville_depart': departureCity,
      'ville_arrivee': arrivalCity,
      'heure_depart': departureTime.toIso8601String(),
      'heure_arrivee': arrivalTime.toIso8601String(),
      'prix': price,
      'nombre_places': totalSeats,
      'places_restantes': availableSeats,
      'statut': isAvailable ? 'DISPONIBLE' : 'INDISPONIBLE',
    };
  }
}