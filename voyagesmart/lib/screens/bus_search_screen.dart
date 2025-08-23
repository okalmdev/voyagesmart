import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'bus_list_screen.dart';

class BusSearchScreen extends StatefulWidget {
  const BusSearchScreen({Key? key}) : super(key: key);

  @override
  State<BusSearchScreen> createState() => _BusSearchScreenState();
}

class _BusSearchScreenState extends State<BusSearchScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _searchTrips() async {
    final departure = _departureController.text.trim();
    final arrival = _arrivalController.text.trim();

    if (departure.isEmpty || arrival.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    try {
      // Loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );

      final results = await ApiService.searchBusTrips(
        villeDepart: departure,
        villeArrivee: arrival,
        dateDepart: DateFormat('yyyy-MM-dd').format(selectedDate!),
      );

      if (!mounted) return;
      Navigator.pop(context); // ferme le loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BusListScreen(trips: results),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  InputDecoration _greenInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: const Color(0xFFE8F5E9),
      labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
      onPressed: () {
        final cities = label.split("→");
        _departureController.text = cities[0].trim();
        _arrivalController.text = cities[1].trim();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
        title: const Text(
          "Rechercher un trajet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _departureController,
              decoration: _greenInputDecoration("Ville de départ", Icons.location_on),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _arrivalController,
              decoration: _greenInputDecoration("Ville d’arrivée", Icons.flag),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: _greenInputDecoration(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                        : "Date de voyage",
                    Icons.calendar_today,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text("Rechercher"),
                onPressed: _searchTrips,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Suggestions populaires 🔥",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _suggestionChip("Bamako → Ségou"),
                _suggestionChip("Bamako → Sikasso"),
                _suggestionChip("Kayes → Bamako"),
                _suggestionChip("Ségou → Mopti"),
                _suggestionChip("Koutiala → Bamako"),
                _suggestionChip("Bamako → Mopti"),
                _suggestionChip("Bamako → Kati"),
                _suggestionChip("Mopti → Bandiagara"),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
