import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../services/api_service.dart';
import 'hotel_details_screen.dart';

class HotelListScreen extends StatefulWidget {
  final String ville;
  final DateTime dateArrivee;
  final DateTime dateDepart;
  final bool localOnly;

  const HotelListScreen({
    Key? key,
    required this.ville,
    required this.dateArrivee,
    required this.dateDepart,
    this.localOnly = false,
  }) : super(key: key);

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late Future<List<Hotel>> _hotelsFuture;

  @override
  void initState() {
    super.initState();

    final dateArriveeStr = widget.dateArrivee.toIso8601String();
    final dateDepartStr = widget.dateDepart.toIso8601String();

    _hotelsFuture = widget.localOnly
        ? ApiService.getLocalHotelsByVille(widget.ville)
        : ApiService.getHotelsByVilleEtDates(
      ville: widget.ville,
      dateArrivee: dateArriveeStr,
      dateDepart: dateDepartStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hôtels à ${widget.ville} du '
              '${widget.dateArrivee.day}/${widget.dateArrivee.month} '
              'au ${widget.dateDepart.day}/${widget.dateDepart.month}',
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: FutureBuilder<List<Hotel>>(
        future: _hotelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final hotels = snapshot.data ?? [];
          if (hotels.isEmpty) {
            return const Center(child: Text("Aucun hôtel trouvé."));
          }

          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: hotel.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      hotel.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.hotel, size: 40, color: Colors.grey),
                  title: Text(
                    hotel.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.adresse),
                      const SizedBox(height: 4),
                      Text("Prix: ${hotel.prix.toStringAsFixed(0)} FCFA / nuit",
                          style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailScreen(hotel: hotel),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
