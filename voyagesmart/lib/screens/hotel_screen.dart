import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'hotel_list_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  final List<String> suggestions;

  const HotelSearchScreen({
    Key? key,
    this.suggestions = const [
      "Bamako",
      "Ségou",
      "Kayes",
      "Sikasso",
      "Mopti",
      "Koutiala",
      "Kati",
      "Bandiagara",
    ],
  }) : super(key: key);

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final TextEditingController _villeController = TextEditingController();
  DateTime? dateArrivee;

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateArrivee ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => dateArrivee = picked);
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
        _villeController.text = label;
      },
    );
  }

  void _searchHotels() {
    final ville = _villeController.text.trim();
    if (ville.isEmpty || dateArrivee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    final dateDepart = dateArrivee!.add(const Duration(days: 1));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelListScreen(
          ville: ville,
          dateArrivee: dateArrivee!,
          dateDepart: dateDepart,
        ),
      ),
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
          "Rechercher un hôtel",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _villeController,
              decoration: _greenInputDecoration("Ville ou Localisation", Icons.location_city),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: _greenInputDecoration(
                    dateArrivee != null
                        ? DateFormat('dd/MM/yyyy').format(dateArrivee!)
                        : "Date d'arrivée",
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
                onPressed: _searchHotels,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Suggestions populaires 🏨",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.suggestions.map(_suggestionChip).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
