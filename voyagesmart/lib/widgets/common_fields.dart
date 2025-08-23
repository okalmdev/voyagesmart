import 'package:flutter/material.dart';

class CommonField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const CommonField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

class TimeField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const TimeField({
    Key? key,
    required this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _selectTime(context),
      icon: const Icon(Icons.access_time_outlined),
      label: Text(
        selectedTime == null
            ? "Sélectionner l'heure de départ"
            : selectedTime!.format(context),
      ),
    );
  }
}

class ReservationFields extends StatelessWidget {
  final TextEditingController departController;
  final TextEditingController arriveeController;
  final TimeOfDay selectedTime;
  final VoidCallback onTimeTap;

  const ReservationFields({
    Key? key,
    required this.departController,
    required this.arriveeController,
    required this.selectedTime,
    required this.onTimeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonField(
          controller: departController,
          label: "Lieu de départ",
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        CommonField(
          controller: arriveeController,
          label: "Lieu d’arrivée",
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onTimeTap,
          icon: const Icon(Icons.access_time),
          label: Text("Heure : ${selectedTime.format(context)}"),
        ),
      ],
    );
  }
}
