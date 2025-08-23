import 'package:flutter/material.dart';

class TaxiList extends StatelessWidget {
  final List<Map<String, dynamic>> taxis;
  final void Function(Map<String, dynamic> taxi) onTaxiTap;
  final void Function(String phone) onCallTap;

  const TaxiList({
    Key? key,
    required this.taxis,
    required this.onTaxiTap,
    required this.onCallTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (taxis.isEmpty) {
      return const Center(
        child: Text("Aucun taxi disponible."),
      );
    }

    return ListView.separated(
      itemCount: taxis.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final taxi = taxis[index];
        final driverName = taxi['driver_name'] ?? "Inconnu";
        final phone = taxi['phone'] ?? "";
        final city = taxi['city'] ?? "";
        final disponible = taxi['disponible'] ?? false;

        return ListTile(
          leading: Icon(
            disponible ? Icons.local_taxi : Icons.local_taxi_outlined,
            color: disponible ? Colors.green : Colors.grey,
            size: 32,
          ),
          title: Text(driverName),
          subtitle: Text(city),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.blue),
            onPressed: () => onCallTap(phone),
            tooltip: "Appeler $driverName",
          ),
          onTap: disponible ? () => onTaxiTap(taxi) : null,
        );
      },
    );
  }
}
