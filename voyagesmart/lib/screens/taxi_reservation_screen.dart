import 'package:flutter/material.dart';
import '../models/taxi_model.dart';
import '../services/api_service.dart';
import 'taxi_qr_screen.dart';

class TaxiReservationScreen extends StatefulWidget {
  final String userId;
  final Taxi taxi;

  const TaxiReservationScreen({
    super.key,
    required this.userId,
    required this.taxi,
  });

  @override
  State<TaxiReservationScreen> createState() => _TaxiReservationScreenState();
}

class _TaxiReservationScreenState extends State<TaxiReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool isLoading = false;

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate() || _selectedTime == null) return;

    setState(() => isLoading = true);

    try {
      final heure = _selectedTime!.format(context);

      final reservation = await ApiService.reserveTaxi(
        userId: widget.userId,
        taxiId: widget.taxi.id,
        lieuDepart: _departController.text,
        lieuArrivee: _arriveeController.text,
        heureDepart: heure,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TaxiQrScreen(reservationData: reservation),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réserver un Taxi"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _departController,
                decoration: const InputDecoration(
                  labelText: "Lieu de départ",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _arriveeController,
                decoration: const InputDecoration(
                  labelText: "Lieu d’arrivée",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? "Heure non choisie"
                          : "Heure : ${_selectedTime!.format(context)}",
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                    child: const Text("Choisir l’heure"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirmer la réservation"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
