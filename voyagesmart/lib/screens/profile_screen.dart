import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;

  const ProfileScreen({required this.userName, Key? key}) : super(key: key);

  final Map<String, String> userInfo = const {
    "email": "cissefatou957@gmail.com",
    "phone": "72904838",
  };

  final List<Map<String, String>> reservations = const [
    {"type": "Bus", "detail": "Bamako → Sikasso", "status": "Confirmée"},
    {"type": "Hôtel", "detail": "Hotel Résidence - 3 nuits", "status": "En attente"},
    {"type": "Taxi", "detail": "Taxi aéroport", "status": "Annulée"},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case "Confirmée":
        return Colors.green;
      case "En attente":
        return Colors.orange;
      case "Annulée":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getReservationIcon(String type) {
    switch (type) {
      case "Bus":
        return Icons.directions_bus;
      case "Hôtel":
        return Icons.hotel;
      case "Taxi":
        return Icons.local_taxi;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text("Profil de $userName"),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar et nom
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green.shade100,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '',
                style: const TextStyle(fontSize: 40, color: Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 15),
            Text(userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(userInfo['email']!,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            Text(userInfo['phone']!,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 25),

            // Infos section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Mes Réservations",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Divider(thickness: 1.1),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Liste des réservations
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                      child: Icon(
                        _getReservationIcon(res['type']!),
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    title: Text(res['type']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(res['detail']!,
                        style: const TextStyle(color: Colors.black87)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(res['status']!).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        res['status']!,
                        style: TextStyle(
                          color: _getStatusColor(res['status']!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
