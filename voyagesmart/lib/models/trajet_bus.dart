class TrajetBus {
  final String compagnie;
  final String villeDepart;
  final String villeArrivee;
  final String heureDepart;
  final String heureArrivee;
  final int prix;
  final int placesTotales;
  final int placesDisponibles;
  final DateTime date;

  TrajetBus({
    required this.compagnie,
    required this.villeDepart,
    required this.villeArrivee,
    required this.heureDepart,
    required this.heureArrivee,
    required this.prix,
    required this.placesTotales,
    required this.placesDisponibles,
    required this.date,
  });

  // Convertir en Map pour la compatibilité
  Map<String, dynamic> toMap() {
    return {
      'compagnie': compagnie,
      'ville_depart': villeDepart,
      'ville_arrivee': villeArrivee,
      'heure_depart': heureDepart,
      'heure_arrivee': heureArrivee,
      'prix': prix,
      'places_totales': placesTotales,
      'places_disponibles': placesDisponibles,
      'date': date,
    };
  }

  // Méthode factory pour créer à partir d'une Map
  factory TrajetBus.fromMap(Map<String, dynamic> map) {
    return TrajetBus(
      compagnie: map['compagnie'] ?? '',
      villeDepart: map['ville_depart'] ?? '',
      villeArrivee: map['ville_arrivee'] ?? '',
      heureDepart: map['heure_depart'] ?? '',
      heureArrivee: map['heure_arrivee'] ?? '',
      prix: map['prix'] ?? 0,
      placesTotales: map['places_totales'] ?? 0,
      placesDisponibles: map['places_disponibles'] ?? 0,
      date: map['date'] is DateTime ? map['date'] : DateTime.now(),
    );
  }
}