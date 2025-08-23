import 'package:flutter/material.dart';
import '../models/bus_trip.dart';
import '../services/api_service.dart';
import 'bus_list_screen.dart';

class BusTripsLoaderScreen extends StatefulWidget {
  const BusTripsLoaderScreen({Key? key}) : super(key: key);

  @override
  _BusTripsLoaderScreenState createState() => _BusTripsLoaderScreenState();
}

class _BusTripsLoaderScreenState extends State<BusTripsLoaderScreen> {
  late Future<List<BusTrip>> futureTrips;

  @override
  void initState() {
    super.initState();
    futureTrips = ApiService.getBusTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des trajets")),
      body: FutureBuilder<List<BusTrip>>(
        future: futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun trajet disponible.'));
          } else {
            return BusListScreen(trips: snapshot.data!);
          }
        },
      ),
    );
  }
}
