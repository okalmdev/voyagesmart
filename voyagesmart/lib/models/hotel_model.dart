class Hotel {
  final int id;
  final String nom;
  final String adresse;
  final String telephone;
  final String email;
  final String description;
  final double latitude;
  final double longitude;
  final int villeId;
  final String imageUrl;
  final double prix; // ✅ Ajout du champ prix

  Hotel({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.email,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.villeId,
    required this.imageUrl,
    required this.prix, // ✅ Ajout ici aussi
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      email: json['email'],
      description: json['description'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      villeId: json['ville_id'],
      imageUrl: json['image_url'] ?? '',
      prix: double.tryParse(json['prix'].toString()) ?? 0.0, // ✅ Ajout avec conversion sûre
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'ville_id': villeId,
      'image_url': imageUrl,
      'prix': prix, // ✅ Ajout ici aussi
    };
  }
}
