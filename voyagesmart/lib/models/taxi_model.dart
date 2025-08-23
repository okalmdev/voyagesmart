// lib/models/taxi_model.dart

class Taxi {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isAvailable;

  Taxi({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
  });

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
    };
  }
}
