import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HotelConfirmationScreen extends StatelessWidget {
  final String hotelName;
  final String reservationCode;

  const HotelConfirmationScreen({
    Key? key,
    required this.hotelName,
    required this.reservationCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation de réservation")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Réservation confirmée à :",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              hotelName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: reservationCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            Text(
              "Code: $reservationCode",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
