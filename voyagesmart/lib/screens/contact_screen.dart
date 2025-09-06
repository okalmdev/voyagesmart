import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // 🔹 Données de contact par catégorie
  final Map<String, Map<String, String>> contacts = const {
    "Bus": {
      "Téléphone": "+22370001122",
      "Email": "support.bus@voyagesmart.com",
      "WhatsApp": "+22370001122"
    },
    "Hôtel": {
      "Téléphone": "+22370112233",
      "Email": "support.hotel@voyagesmart.com",
      "WhatsApp": "+22370112233"
    },
    "Taxi": {
      "Téléphone": "+22370223344",
      "Email": "support.taxi@voyagesmart.com",
      "WhatsApp": "+22370223344"
    },
  };

  // 🔹 Méthodes pour actions
  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final Uri uri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Contactez-nous",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Besoin d’aide ?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choisissez une catégorie pour obtenir nos coordonnées.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // 🔹 Générer les cartes avec animation
            ...contacts.entries.map((entry) {
              final category = entry.key;
              final data = entry.value;
              return _AnimatedContactCard(
                category: category,
                data: data,
                callPhone: _callPhone,
                sendEmail: _sendEmail,
                openWhatsApp: _openWhatsApp,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// 🔹 Widget animé pour chaque carte
class _AnimatedContactCard extends StatefulWidget {
  final String category;
  final Map<String, String> data;
  final Function(String) callPhone;
  final Function(String) sendEmail;
  final Function(String) openWhatsApp;

  const _AnimatedContactCard({
    required this.category,
    required this.data,
    required this.callPhone,
    required this.sendEmail,
    required this.openWhatsApp,
  });

  @override
  State<_AnimatedContactCard> createState() => _AnimatedContactCardState();
}

class _AnimatedContactCardState extends State<_AnimatedContactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _pressed ? 2 : 6,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // 🔹 Header vert
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  widget.category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // 🔹 Corps blanc avec infos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    _buildContactRow(
                      icon: Icons.phone,
                      label: widget.data["Téléphone"]!,
                      onTap: () => widget.callPhone(widget.data["Téléphone"]!),
                    ),
                    const SizedBox(height: 10),
                    _buildContactRow(
                      icon: Icons.email,
                      label: widget.data["Email"]!,
                      onTap: () => widget.sendEmail(widget.data["Email"]!),
                    ),
                    const SizedBox(height: 10),
                    _buildContactRow(
                      icon: FontAwesomeIcons.whatsapp,
                      label: "WhatsApp",
                      onTap: () => widget.openWhatsApp(widget.data["WhatsApp"]!),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Ligne contact réutilisable
  Widget _buildContactRow(
      {required IconData icon,
        required String label,
        required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
