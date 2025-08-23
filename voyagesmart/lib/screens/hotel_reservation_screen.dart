import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import 'hotel_qr_screen.dart';

class HotelReservationScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelReservationScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelReservationScreen> createState() => _HotelReservationScreenState();
}

class _HotelReservationScreenState extends State<HotelReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  String phone = '';
  DateTime? dateArrivee;
  DateTime? dateDepart;
  String? typeChambre;
  int? nombrePersonnes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Réserver l'hôtel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Hôtel: ${widget.hotel.nom}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom complet'),
                onSaved: (val) => fullName = val ?? '',
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                onSaved: (val) => phone = val ?? '',
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => dateArrivee = picked);
                      },
                      child: Text(dateArrivee == null
                          ? 'Date arrivée'
                          : 'Arrivée: ${dateArrivee!.toLocal()}'.split(' ')[0]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dateArrivee ?? DateTime.now(),
                          firstDate: dateArrivee ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => dateDepart = picked);
                      },
                      child: Text(dateDepart == null
                          ? 'Date départ'
                          : 'Départ: ${dateDepart!.toLocal()}'.split(' ')[0]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: typeChambre,
                hint: const Text('Type de chambre'),
                items: ['Simple', 'Double', 'Suite'].map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (val) => setState(() => typeChambre = val),
                validator: (val) => val == null ? 'Champ requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de personnes'),
                keyboardType: TextInputType.number,
                onSaved: (val) => nombrePersonnes = int.tryParse(val ?? ''),
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Confirmer & Générer QR'),
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      dateArrivee != null &&
                      dateDepart != null) {
                    _formKey.currentState!.save();

                    final code = "HOTEL-${widget.hotel.id}-${DateTime.now().millisecondsSinceEpoch}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelQrScreen(
                          hotel: widget.hotel,
                          fullName: fullName,
                          phone: phone,
                          dateArrivee: dateArrivee!,
                          dateDepart: dateDepart!,
                          typeChambre: typeChambre!,
                          nombrePersonnes: nombrePersonnes!,
                        ),
                      ),
                    );

                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
