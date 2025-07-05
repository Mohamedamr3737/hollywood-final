import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/AppointmentsController.dart';
import '../../../auth/controller/token_controller.dart'; // for refreshAccessToken()
import '../../../../general/widgets/DateTimeSlotSelector.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment ID is missing.")),
        );
        return;
      }

      final int id = int.parse(idStr);
      final success = await appointmentsController.cancelAppointment(id: id);
      if (success) {
        // Return a Map<String, String> with a guaranteed non-null 'id'.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your Reservation time has been canceled.")),
        );
        Navigator.of(context).pop({
          'action': 'cancel',
          'id': widget.appointment['id'] ?? '',
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appointmentsController.errorMessage.value)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Show date picker and set the date field.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      final y = selected.year.toString();
      final m = selected.month.toString().padLeft(2, '0');
      final d = selected.day.toString().padLeft(2, '0');
      setState(() {
        _dateCtrl.text = "$y-$m-$d";
      });
    }
  }

  /// Show time picker and set the time field.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final ampm = picked.period == DayPeriod.am ? "AM" : "PM";
      setState(() {
        _timeCtrl.text = "$hour:$minute $ampm";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare available dates (next 7 days)
    final now = DateTime.now();
    final availableDates = List<DateTime>.generate(7, (i) => now.add(Duration(days: i)));
    DateTime? selectedDateObj = _dateCtrl.text.isNotEmpty ? DateTime.tryParse(_dateCtrl.text) : null;
    String? selectedTime = _timeCtrl.text.isNotEmpty ? _timeCtrl.text : null;
    // For demo: use static times, in real use, fetch from controller
    final availableTimes = [
      '8:00:00AM', '9:00:00AM', '10:00:00AM', '11:00:00AM',
      '12:00:00PM', '1:00:00PM', '2:00:00PM', '3:00:00PM',
      '4:00:00PM', '5:00:00PM', '6:00:00PM', '7:00:00PM',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Modern Header
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D8F),
                  Color(0xFF1A5F6F),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              image: DecorationImage(
                image: const NetworkImage('https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFF2E7D8F).withOpacity(0.8),
                  BlendMode.overlay,
                ),
              ),
            ),
            child: Stack(
              children: [
                // AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Edit Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // Circular Icon and Title
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_calendar,
                          size: 50,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Update Appointment Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Appointment Name Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Appointment Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _appointmentNameCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2E7D8F), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Department Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Department",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _departmentCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2E7D8F), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // DateTimeSlotSelector
                  DateTimeSlotSelector(
                    title: 'Edit Date & Time',
                    availableDates: availableDates,
                    availableTimes: availableTimes,
                    selectedDate: selectedDateObj,
                    selectedTime: selectedTime,
                    onDateSelected: (date) {
                      setState(() {
                        _dateCtrl.text = date.toIso8601String().split('T')[0];
                        _timeCtrl.text = '';
                      });
                    },
                    onTimeSelected: (time) {
                      setState(() {
                        _timeCtrl.text = time;
                      });
                    },
                    onConfirm: _saveChanges,
                    confirmText: 'Save Changes',
                  ),
                  // Cancel Appointment Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      onPressed: _cancelAppointment,
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text(
                        "Cancel Appointment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
