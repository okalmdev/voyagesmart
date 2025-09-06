import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../models/bus_trip.dart';
import '../data/sample_hotels.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final BusTrip trip;
  final List<String> selectedSeats;
  final String fullName;
  final String phone;
  final String? reservationId;

  const BookingConfirmationScreen({
    Key? key,
    required this.trip,
    required this.selectedSeats,
    required this.fullName,
    required this.phone,
    this.reservationId,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool saving = false;

  String get qrData {
    return '''
Réservation Voyage Smart
ID: ${widget.reservationId ?? 'N/A'}
Nom: ${widget.fullName}
Téléphone: ${widget.phone}
Trajet: ${widget.trip.departureCity} → ${widget.trip.arrivalCity}
Date: ${widget.trip.formattedDate}
Heure: ${widget.trip.formattedDepartureTime}
Sièges: ${widget.selectedSeats.join(', ')}
Montant: ${widget.trip.price * widget.selectedSeats.length} FCFA
Compagnie: ${widget.trip.company}
''';
  }

  List<Map<String, String>> get recommendedHotels {
    final destination = widget.trip.arrivalCity.toLowerCase();
    return hotels.where((hotel) {
      return (hotel['city'] ?? '').toLowerCase() == destination;
    }).toList();
  }

  Future<void> _shareQrCode() async {
    try {
      setState(() => saving = true);
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/qr_voyage_smart.png');
      await imagePath.writeAsBytes(image); // ✅ écrit l'image dans le fichier

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Ma réservation Voyage Smart 🚍\n\n$qrData',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du partage : ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => saving = true);
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaverPlus.saveImage(
          image,
          quality: 100,
          name:
          "VoyageSmart_${widget.reservationId ?? DateTime.now().millisecondsSinceEpoch}",
        );

        if ((result['isSuccess'] == true || result['filePath'] != null) &&
            mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR Code enregistré dans la galerie")),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.trip.price * widget.selectedSeats.length;

    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Confirmation", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Confirmation
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 50),
                    const SizedBox(height: 8),
                    const Text("Réservation confirmée !",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (widget.reservationId != null) ...[
                      const SizedBox(height: 8),
                      Text("Référence: ${widget.reservationId}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🚌 Détails du voyage
            const Text("Détails du voyage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow("🚌 Compagnie:", widget.trip.company),
                    _buildInfoRow("📍 Trajet:",
                        "${widget.trip.departureCity} → ${widget.trip.arrivalCity}"),
                    _buildInfoRow("📅 Date:", widget.trip.formattedDate),
                    _buildInfoRow("⏰ Départ:", widget.trip.formattedDepartureTime),
                    _buildInfoRow("🏁 Arrivée:", widget.trip.formattedArrivalTime),
                    _buildInfoRow("⏳ Durée:", widget.trip.duration),
                    _buildInfoRow("💺 Sièges:",
                        widget.selectedSeats.join(', ')),
                    _buildInfoRow("💰 Total:", "$totalPrice FCFA"),
                    _buildInfoRow("👤 Passager:", widget.fullName),
                    _buildInfoRow("📞 Téléphone:", widget.phone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔳 QR Code
            const Text("QR Code de réservation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Screenshot(
              controller: _screenshotController,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200,
                        foregroundColor: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      const Text("Voyage Smart",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💾 Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _saveToGallery,
                    icon: saving
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download),
                    label: Text(saving ? "En cours..." : "Enregistrer"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : _shareQrCode,
                    icon: const Icon(Icons.share),
                    label: const Text("Partager"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),

            // 🏨 Hôtels recommandés
            if (recommendedHotels.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              Text("🏨 Hôtels recommandés à ${widget.trip.arrivalCity}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...recommendedHotels.map((hotel) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                  const Icon(Icons.hotel, color: Color(0xFF4CAF50)),
                  title: Text(hotel['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel['address'] ?? ''),
                      const SizedBox(height: 4),
                      Text("${hotel['price']} FCFA/nuit",
                          style:
                          const TextStyle(color: Color(0xFF4CAF50))),
                    ],
                  ),
                ),
              )),
            ],

            const SizedBox(height: 24),

            // ➕ Nouvelle réservation
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFF4CAF50)),
                label: const Text("Nouvelle réservation",
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
