import 'package:flutter/material.dart';
import '../../../auth/controller/token_controller.dart';

class MyAppointmentsPage extends StatelessWidget {
  final List<Map<String, String>> appointments;
  final Function(Map<String, String>) onTapAppointment;

  const MyAppointmentsPage({
    Key? key,
    required this.appointments,
    required this.onTapAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkLoginStatus();
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_note, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Empty Appointments!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.orange[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTapAppointment(appt),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment name & doctor at top.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Appointment: ${appt['appointmentName'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        appt['doctor'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date & Department.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: ${appt['date'] ?? ''}  ${appt['time'] ?? ''}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Dept: ${appt['department'] ?? ''}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
