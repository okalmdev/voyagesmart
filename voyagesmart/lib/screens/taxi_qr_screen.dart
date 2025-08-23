import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TaxiQrScreen extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const TaxiQrScreen({Key? key, required this.reservationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrContent = reservationData.entries
        .map((e) => "${e.key}: ${e.value}")
        .join('\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Votre QR Code"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrContent,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            const Text(
              "Montrez ce QR Code au chauffeur",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
