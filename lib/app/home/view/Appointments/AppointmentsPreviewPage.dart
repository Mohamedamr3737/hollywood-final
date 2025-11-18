import 'package:flutter/material.dart';
import 'AppointmentDetailsPage.dart';

class AppointmentPreviewPage extends StatelessWidget {
  final Map<String, String> appointment;

  const AppointmentPreviewPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apptName = appointment['appointmentName'] ?? '';
    final doctor = appointment['doctor'] ?? '';
    final department = appointment['department'] ?? '';
    final date = appointment['date'] ?? '';
    final time = appointment['time'] ?? '';

    return Scaffold(
      // The background + top bar
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                // The same sparkly background
                child: Image.network(
                  'https://images.unsplash.com/photo-1601984845798-44b10f90c361?ixlib=rb-4.0.3&q=80&w=1400',
                  fit: BoxFit.cover,
                ),
              ),
              // Extra space for the circle icon
              const SizedBox(height: 100),
            ],
          ),
          // Circle lotus
          Positioned(
            top: 140,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.network(
                  'https://cdn3.iconfinder.com/data/icons/zen-2/100/Lotus_5-512.png',
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            top: 280,
            child: Column(
              children: [
                // Title
                const Text(
                  "My Appointment",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Appointment Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabelValue("Appointment", apptName),
                      const Divider(),
                      _buildLabelValue("Doctor", doctor),
                      const Divider(),
                      _buildLabelValue("Department", department),
                      const Divider(),
                      _buildLabelValue("Date", "$date  $time"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Edit & Cancel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Edit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            // Navigate to the edit page
                            final updatedAppt =
                            await Navigator.of(context).push<Map<String, String>>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AppointmentDetailPage(appointment: appointment),
                              ),
                            );
                            // If user saved changes, pop with "update" action
                            if (updatedAppt != null) {
                              Navigator.of(context).pop({
                                'action': 'update',
                                'data': updatedAppt,
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // Return with "cancel" action
                            Navigator.of(context).pop({
                              'action': 'cancel',
                              'id': appointment['id'],
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Custom app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "My Appointment",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the appointment info row
  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}