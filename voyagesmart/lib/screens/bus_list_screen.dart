import 'package:flutter/material.dart';
import '../models/bus_trip.dart';
import 'bus_trip_details_screen.dart';

class BusListScreen extends StatelessWidget {
  final List<BusTrip> trips;
  final String? currentCity;

  const BusListScreen({
    Key? key,
    required this.trips,
    this.currentCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentCity != null
              ? "Bus depuis $currentCity"
              : "Résultats de recherche",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
      ),
      body: trips.isEmpty
          ? const Center(
        child: Text(
          "Aucun trajet disponible pour ces critères.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: trips.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_bus,
                    color: Color(0xFF4CAF50),
                    size: 30,
                  ),
                  if (!trip.isAvailable)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COMPLET',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                "${trip.departureCity} → ${trip.arrivalCity}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Compagnie: ${trip.company}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "${trip.formattedDate} • ${trip.departureTime} → ${trip.arrivalTime}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Durée: ${trip.duration} • Places: ${trip.availableSeats}/${trip.totalSeats}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${trip.price} FCFA",
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF4CAF50)),
                ],
              ),
              onTap: trip.isAvailable
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BusTripDetailsScreen(trip: trip),
                  ),
                );
              }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
