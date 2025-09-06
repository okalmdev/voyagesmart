class Taxi {
  final String id;
  final String chauffeur;
  final String phone;
  final String ville;
  final bool disponible;
  final double latitude;
  final double longitude;
  final String? image;

  Taxi({
    required this.id,
    required this.chauffeur,
    required this.phone,
    required this.ville,
    required this.disponible,
    required this.latitude,
    required this.longitude,
    this.image,
  });

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['id'].toString(),
      chauffeur: json['chauffeur'] ?? '',
      phone: json['phone'] ?? '',
      ville: json['ville'] ?? '',
      disponible: json['disponible'] ?? false,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      image: json['image'],
    );
  }
}
