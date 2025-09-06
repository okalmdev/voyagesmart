import 'package:flutter/material.dart';

class PartnerDetailScreen extends StatelessWidget {
  final Map<String, String> partner;

  const PartnerDetailScreen({super.key, required this.partner});

  // Exemple de données simulées pour les offres
  List<Map<String, String>> getOffers(String partnerName) {
    switch (partnerName) {
      case "DIARRA TRANSPORT":
        return [
          {"route": "Bamako → Sikasso", "heure": "08:00", "prix": "5000 FCFA"},
          {"route": "Bamako → Kayes", "heure": "12:00", "prix": "7000 FCFA"},
        ];
      case "NOUR TRANSPORT":
        return [
          {"route": "Bamako → Mopti", "heure": "09:00", "prix": "6000 FCFA"},
        ];
      case "AIR NIONO":
        return [
          {"route": "Bamako → Aéroport", "heure": "07:00", "prix": "15000 FCFA"},
        ];
      case "SONEF HOTEL":
        return [
          {"route": "Chambre simple", "heure": "-", "prix": "20000 FCFA"},
          {"route": "Chambre double", "heure": "-", "prix": "35000 FCFA"},
        ];
      default:
        return [];
    }
  }

  // Exemple de détails simulés
  Map<String, String> getDetails(String partnerName) {
    switch (partnerName) {
      case "DIARRA TRANSPORT":
        return {
          "adresse": "Avenue de l’Indépendance, Bamako",
          "telephone": "+223 70 00 00 00",
          "email": "contact@diarratransport.ml",
          "description":
          "DIARRA TRANSPORT est une compagnie fiable offrant des voyages sécurisés et confortables à travers le Mali."
        };
      case "NOUR TRANSPORT":
        return {
          "adresse": "Rue du Marché, Mopti",
          "telephone": "+223 75 11 22 33",
          "email": "infos@nourtransport.ml",
          "description":
          "NOUR TRANSPORT propose des liaisons régulières entre Bamako et les grandes villes du Mali."
        };
      case "AIR NIONO":
        return {
          "adresse": "Aéroport International Modibo Keïta, Bamako",
          "telephone": "+223 79 88 77 66",
          "email": "support@airniono.ml",
          "description":
          "AIR NIONO est spécialisée dans les vols domestiques avec un service rapide et efficace."
        };
      case "SONEF HOTEL":
        return {
          "adresse": "Quartier du Fleuve, Bamako",
          "telephone": "+223 67 55 44 33",
          "email": "reservation@sonefhotel.ml",
          "description":
          "SONEF HOTEL propose un hébergement de qualité avec des chambres modernes et confortables."
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = getOffers(partner['name']!);
    final details = getDetails(partner['name']!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          partner['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo + Catégorie
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage(partner['image']!),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner['name']!,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        partner['category']!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Détails du partenaire
            if (details.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details['description']!,
                          style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(details['adresse']!)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(details['telephone']!),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(details['email']!)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Liste des offres
            Text("Programme & Offres disponibles",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade700)),
            const SizedBox(height: 12),

            offers.isEmpty
                ? const Center(
              child: Text("Aucune offre disponible pour le moment.",
                  style: TextStyle(color: Colors.black54, fontSize: 16)),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      offer['route']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text("Heure : ${offer['heure']}  |  Prix : ${offer['prix']}"),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.green),
                    onTap: () {
                      // TODO: ouvrir détails de réservation
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
