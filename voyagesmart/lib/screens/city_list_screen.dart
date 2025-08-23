// screens/city_list_screen.dart
import 'package:flutter/material.dart';
import '../data/static_cities.dart';
import '../models/city_model.dart';

class CityListScreen extends StatelessWidget {
  const CityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des villes"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: staticCities.length,
        itemBuilder: (context, index) {
          City city = staticCities[index];
          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(city.name),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Vous avez sélectionné ${city.name}")),
              );
            },
          );
        },
      ),
    );
  }
}
