// medication_tab.dart
import 'package:flutter/material.dart';
import 'MedicationDetailPage.dart';
import '../../controller/medication_controller.dart';

class MedicationTab extends StatefulWidget {
  const MedicationTab({Key? key}) : super(key: key);

  @override
  State<MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<MedicationTab> {
  late Future<List<dynamic>> _futureMeds;
  late MedicationController _medicationController;

  @override
  void initState() {
    super.initState();
    _medicationController = MedicationController();
    _futureMeds = _medicationController.fetchMyPrescriptions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureMeds,
      builder: (context, snapshot) {
        // 1) Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // 3) Data
        final meds = snapshot.data;
        if (meds == null || meds.isEmpty) {
          return const Center(
            child: Text(
              "No Medication Prescriptions",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meds.length,
          itemBuilder: (ctx, index) {
            final prescription = meds[index];
            final doctorName = prescription['doctor']?['name'] ?? 'Unknown Doctor';
            final presId = prescription['id']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  "Doctor\n$doctorName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "Prescription ID: $presId",
                  style: const TextStyle(fontSize: 14),
                ),
                onTap: () {
                  // Navigate to medication detail page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MedicationDetailPage(
                        prescription: prescription, // the full prescription Map
                      ),
                    ),
                  );

                },
              ),
            );
          },
        );
      },
    );
  }
}
