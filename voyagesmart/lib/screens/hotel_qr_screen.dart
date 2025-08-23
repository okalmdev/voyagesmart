import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../models/hotel_model.dart';

class HotelQrScreen extends StatelessWidget {
  final Hotel hotel;
  final String fullName;
  final String phone;
  final DateTime dateArrivee;
  final DateTime dateDepart;
  final String typeChambre;
  final int nombrePersonnes;

  HotelQrScreen({
    Key? key,
    required this.hotel,
    required this.fullName,
    required this.phone,
    required this.dateArrivee,
    required this.dateDepart,
    required this.typeChambre,
    required this.nombrePersonnes,
  }) : super(key: key);

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final qrData = '''
Hôtel: ${hotel.nom}
Nom: $fullName
Téléphone: $phone
Date d’arrivée: ${_formatDate(dateArrivee)}
Date de départ: ${_formatDate(dateDepart)}
Type de chambre: $typeChambre
Nombre de personnes: $nombrePersonnes
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR de Réservation"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async => await _shareScreenshot(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async => await _downloadScreenshot(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Screenshot(
          controller: screenshotController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hotel.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Votre Code QR de Réservation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Détails de la Réservation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _infoRow('Nom', fullName),
              _infoRow('Téléphone', phone),
              _infoRow('Date d’arrivée', _formatDate(dateArrivee)),
              _infoRow('Date de départ', _formatDate(dateDepart)),
              _infoRow('Type de chambre', typeChambre),
              _infoRow('Personnes', nombrePersonnes.toString()),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _downloadScreenshot(BuildContext context) async {
    final image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reservation_qr.png');
    await file.writeAsBytes(image);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("QR sauvegardé dans les documents")),
    );
  }

  Future<void> _shareScreenshot() async {
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/reservation_qr_shared.png');
    await file.writeAsBytes(image);

    await Share.shareXFiles([XFile(file.path)], text: "Voici ma réservation d'hôtel !");
  }
}
