import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import 'hotel_reservation_screen.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.nom),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hotel.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            Text(hotel.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${hotel.villeId} - ${hotel.adresse}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(hotel.description),
            const SizedBox(height: 10),
            Text('Téléphone : ${hotel.telephone}'),
            Text('Email : ${hotel.email}'),
            const SizedBox(height: 10),
            Text('Prix: ${hotel.prix.toStringAsFixed(0)} FCFA / nuit',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelReservationScreen(hotel: hotel),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Réserver', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
