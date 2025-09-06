import 'package:flutter/material.dart';
import '../models/bus_trip.dart';
import 'booking_confirmation_screen.dart';
import '../services/api_service.dart';

class BusTripDetailsScreen extends StatefulWidget {
  final BusTrip trip;

  const BusTripDetailsScreen({super.key, required this.trip});

  @override
  State<BusTripDetailsScreen> createState() => _BusTripDetailsScreenState();
}

class _BusTripDetailsScreenState extends State<BusTripDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Set<String> selectedSeats = {}; // étiquettes A1, B2, etc.

  bool isLoading = false;
  bool showSeatSelection = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleSeat(String seatLabel) {
    if (selectedSeats.contains(seatLabel)) {
      setState(() => selectedSeats.remove(seatLabel));
    } else {
      if (selectedSeats.length < widget.trip.availableSeats) {
        setState(() => selectedSeats.add(seatLabel));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous ne pouvez sélectionner que ${widget.trip.availableSeats} siège(s).'),
          ),
        );
      }
    }
  }

  Future<void> _confirmBooking() async {
    final fullName = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un siège')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final reservation = await ApiService.reserveBus(
        utilisateurId: 123, // TODO: remplacer par l'ID utilisateur réel
        voyageId: int.parse(widget.trip.id),
        dateReservation: DateTime.now().toIso8601String(),
        numeroPlace: selectedSeats.toList(), // ✅ envoi d'une List<String>
        prix: widget.trip.price * selectedSeats.length,
      );

      if (!mounted) return;

      String? reservationId;
      try {
        final list = (reservation['reservations'] as List?) ?? [];
        if (list.isNotEmpty && list.first is Map && list.first['id'] != null) {
          reservationId = list.first['id'].toString();
        }
      } catch (_) {
        reservationId = null;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            trip: widget.trip,
            selectedSeats: selectedSeats.toList(), // List<String>
            fullName: fullName,
            phone: phone,
            reservationId: reservationId, // peut être null si l’API ne renvoie pas d’id
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildSeat(String seatLabel, {bool isAvailable = true}) {
    final isSelected = selectedSeats.contains(seatLabel);

    return GestureDetector(
      onTap: isAvailable ? () => _toggleSeat(seatLabel) : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50)
              : isAvailable
              ? Colors.white
              : Colors.grey[300],
          border: Border.all(
            color: isAvailable ? const Color(0xFF4CAF50) : Colors.grey,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          seatLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Grille de sièges dynamique : 4 colonnes, nombre de rangées selon totalSeats.
  Widget _buildSeatGrid() {
    final List<String> seatLabels = [];
    const columns = 4;
    final total = widget.trip.totalSeats;
    final totalRows = (total / columns).ceil();

    for (int r = 0; r < totalRows; r++) {
      final letterCode = 'A'.codeUnitAt(0) + r; // A, B, C, ...
      final rowLabel = String.fromCharCode(letterCode);
      for (int c = 1; c <= columns; c++) {
        final seatIndex = r * columns + c;
        if (seatIndex <= total) {
          seatLabels.add('$rowLabel$c'); // A1, A2, ...
        }
      }
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: seatLabels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => _buildSeat(seatLabels[index]),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlighted ? const Color(0xFF4CAF50) : null,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.trip.price * selectedSeats.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Trajet
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_bus, color: Color(0xFF4CAF50), size: 28),
                        const SizedBox(width: 10),
                        Text(
                          widget.trip.company,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Départ:', '${widget.trip.departureCity} à ${widget.trip.formattedDepartureTime}'),
                    _buildInfoRow('Arrivée:', '${widget.trip.arrivalCity} à ${widget.trip.formattedArrivalTime}'),
                    _buildInfoRow('Date:', widget.trip.formattedDate),
                    _buildInfoRow('Durée:', widget.trip.duration),
                    _buildInfoRow('Places:', '${widget.trip.availableSeats} dispo / ${widget.trip.totalSeats}', isHighlighted: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Infos passager
            const Text('Informations passager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: _inputDecoration('Nom complet', Icons.person)),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration('Téléphone', Icons.phone)),

            const SizedBox(height: 20),

            // Sélection des sièges
            if (widget.trip.availableSeats > 0) ...[
              ElevatedButton(
                onPressed: () => setState(() => showSeatSelection = !showSeatSelection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(showSeatSelection ? 'Masquer les sièges' : 'Choisir des sièges', style: const TextStyle(fontSize: 16)),
              ),
              if (showSeatSelection) ...[
                const SizedBox(height: 16),
                const Text('Sélectionnez vos sièges:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSeatGrid(),
                if (selectedSeats.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Sièges: ${selectedSeats.join(', ')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total: $totalPrice FCFA',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ],
              ],
            ],

            const SizedBox(height: 24),

            // Bouton réservation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.trip.isAvailable && !isLoading ? _confirmBooking : null,
                icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle, size: 24),
                label: Text(
                  isLoading
                      ? 'Traitement...'
                      : widget.trip.isAvailable
                      ? 'Confirmer la réservation'
                      : 'Complet',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.trip.isAvailable ? const Color(0xFF4CAF50) : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
