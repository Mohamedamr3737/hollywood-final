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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D8F)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Unable to load medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('${snapshot.error}', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        final meds = snapshot.data;
        if (meds == null || meds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.medication_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text('No Medication Prescriptions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Your medication prescriptions will appear here', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: meds.length,
          itemBuilder: (ctx, index) {
            final prescription = meds[index];
            final doctorName = prescription['doctor']?['name'] ?? 'Unknown Doctor';
            final presId = prescription['id']?.toString() ?? '';
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MedicationDetailPage(
                      prescription: prescription,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication_outlined, color: Color(0xFF2E7D8F), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Doctor', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text('Prescription ID', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          Text(presId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
