import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/common_fields.dart';
import 'taxi_qr_screen.dart';


class TaxiReservationScreen extends StatefulWidget {
  final Map<String, dynamic> taxi;
  final String departure;
  final String arrival;
  final TimeOfDay selectedTime;

  const TaxiReservationScreen({
    Key? key,
    required this.taxi,
    required this.departure,
    required this.arrival,
    required this.selectedTime,
  }) : super(key: key);

  @override
  State<TaxiReservationScreen> createState() => _TaxiReservationScreenState();
}

class _TaxiReservationScreenState extends State<TaxiReservationScreen> {
  late TextEditingController departController;
  late TextEditingController arriveeController;
  late TimeOfDay selectedTime;
  bool isLoading = false;

  // Remplace par l'id réel connecté, en String (si dans le backend c’est un String)
  String userId = '1';

  @override
  void initState() {
    super.initState();
    departController = TextEditingController(text: widget.departure);
    arriveeController = TextEditingController(text: widget.arrival);
    selectedTime = widget.selectedTime;
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _confirmReservation() async {
    if (departController.text.isEmpty || arriveeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await ApiService.reserveTaxi(
        userId: userId,
        taxiId: widget.taxi['id'].toString(),
        dateReservation: today,
        heureDepart: selectedTime.format(context),
        lieuDepart: departController.text.trim(),
        lieuArrivee: arriveeController.text.trim(),
        prix: 3000,
      );


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚖 Réservation confirmée")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TaxiQrScreen(
            reservationData: {
              "chauffeur": widget.taxi['driver_name'] ?? '',
              "téléphone": widget.taxi['phone'] ?? '',
              "ville": widget.taxi['city'] ?? '',
              "départ": departController.text.trim(),
              "arrivée": arriveeController.text.trim(),
              "heure": selectedTime.format(context),
              "prix": "3000 FCFA",
            },
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur : $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    departController.dispose();
    arriveeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxi = widget.taxi;
    return Scaffold(
      appBar: AppBar(
        title: Text("Réserver ${taxi['driver_name'] ?? 'Taxi'}"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(taxi['image'] ?? ''),
                radius: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📍 ${taxi['city'] ?? 'Ville'}", style: const TextStyle(fontSize: 16)),
                    Text("📞 ${taxi['phone'] ?? 'Téléphone'}", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              )
            ]),
            const SizedBox(height: 30),
            ReservationFields(
              departController: departController,
              arriveeController: arriveeController,
              selectedTime: selectedTime,
              onTimeTap: _selectTime,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _confirmReservation,
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.check_circle_outline),
              label: const Text("Confirmer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
