import 'package:flutter/material.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int totalSeats;
  final List<int> occupiedSeats;

  const SeatSelectionScreen({
    Key? key,
    required this.totalSeats,
    required this.occupiedSeats,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<int> selectedSeats = [];

  void toggleSeat(int seatNumber) {
    if (widget.occupiedSeats.contains(seatNumber)) return;

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  Widget buildSeat(int seatNumber) {
    final isOccupied = widget.occupiedSeats.contains(seatNumber);
    final isSelected = selectedSeats.contains(seatNumber);

    Color color;
    if (isOccupied) {
      color = Colors.red;
    } else if (isSelected) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: () => toggleSeat(seatNumber),
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNumber.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = (widget.totalSeats / 4).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélection des sièges"),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Cliquez pour sélectionner vos sièges",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemCount: widget.totalSeats,
                itemBuilder: (context, index) {
                  final seatNumber = index + 1;
                  return buildSeat(seatNumber);
                },
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: selectedSeats.isEmpty
                  ? null
                  : () {
                Navigator.pop(context, selectedSeats);
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirmer les sièges"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
