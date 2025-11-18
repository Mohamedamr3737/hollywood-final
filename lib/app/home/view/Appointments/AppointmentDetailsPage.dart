import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/AppointmentsController.dart';
import '../../../auth/controller/token_controller.dart'; // for refreshAccessToken()
import 'package:s_medi/general/services/alert_service.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Map<String, String> appointment;

  const AppointmentDetailPage({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late TextEditingController _appointmentNameCtrl;
  late TextEditingController _doctorCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;

  // Grab the existing controller from GetX.
  final AppointmentsController appointmentsController = Get.find<AppointmentsController>();

  @override
  void initState() {
    super.initState();
    _appointmentNameCtrl = TextEditingController(
      text: widget.appointment['appointmentName'],
    );
    _doctorCtrl = TextEditingController(
      text: widget.appointment['doctor'],
    );
    _departmentCtrl = TextEditingController(
      text: widget.appointment['department'],
    );
    _dateCtrl = TextEditingController(
      text: widget.appointment['date'],
    );
    _timeCtrl = TextEditingController(
      text: widget.appointment['time'],
    );
  }

  @override
  void dispose() {
    _appointmentNameCtrl.dispose();
    _doctorCtrl.dispose();
    _departmentCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  /// Save the changes and pop with updated data.
  void _saveChanges() {
    final updated = Map<String, String>.from(widget.appointment);
    updated['appointmentName'] = _appointmentNameCtrl.text.trim();
    updated['doctor'] = _doctorCtrl.text.trim();
    updated['department'] = _departmentCtrl.text.trim();
    updated['date'] = _dateCtrl.text.trim();
    updated['time'] = _timeCtrl.text.trim();

    Navigator.of(context).pop(updated);
  }

  /// Cancel the appointment by calling the controller's API method.
  Future<void> _cancelAppointment() async {
    try {
      final idStr = widget.appointment['id'];
      if (idStr == null) {
        AlertService.error(context, "Appointment ID is missing.");
        return;
      }

      final int id = int.parse(idStr);
      final success = await appointmentsController.cancelAppointment(id: id);
      if (success) {
        // Return a Map<String, String> with a guaranteed non-null 'id'.
        AlertService.success(context, "Your Reservation time has been canceled.");
        Navigator.of(context).pop({
          'action': 'cancel',
          'id': widget.appointment['id'] ?? '',
        });
      } else {
        AlertService.error(context, appointmentsController.errorMessage.value);
      }
    } catch (e) {
      AlertService.error(context, "Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a Stack to maintain your original design:
      //  - top background image
      //  - circular lotus icon
      //  - custom AppBar
      body: Stack(
        children: [
          // (1) Background image at the top
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                  fit: BoxFit.cover,
                ),
              ),
              // Extra space to accommodate the circular icon
              const SizedBox(height: 100),
            ],
          ),
          // (2) Circular lotus icon
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
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )

          ),
          // (3) The main content, below the circle
          Positioned.fill(
            top: 280,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Appointment Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _appointmentNameCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _doctorCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Department", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _departmentCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _timeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),


                const SizedBox(height: 16),

                // Cancel Appointment button (full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cancelAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Cancel Appointment",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // (4) Custom AppBar on top
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
                "Appointment Details",
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
}
