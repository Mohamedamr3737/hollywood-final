// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';

class RequestAppointmentPage extends StatefulWidget {
  final void Function(Map<String, String>) onSubmit;

  const RequestAppointmentPage({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<RequestAppointmentPage> createState() => _RequestAppointmentPageState();
}

class _RequestAppointmentPageState extends State<RequestAppointmentPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? _selectedBranch,
      _selectedDepartment,
      _selectedService,
      _selectedDoctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDropdownField("Branch", ["Branch A", "Branch B", "Branch C"],
              (value) {
            _selectedBranch = value;
          }),
          const SizedBox(height: 16),
          _buildDropdownField(
              "Department", ["Cardiology", "Dermatology", "Pediatrics"],
              (value) {
            _selectedDepartment = value;
          }),
          const SizedBox(height: 16),
          _buildDropdownField(
              "Service", ["Service A", "Service B", "Service C"], (value) {
            _selectedService = value;
          }),
          const SizedBox(height: 16),
          _buildDropdownField("Doctor", ["Dr. Smith", "Dr. Jane", "Dr. John"],
              (value) {
            _selectedDoctor = value;
          }),
          const SizedBox(height: 16),
          _buildDateField(context, "Date", _dateController),
          const SizedBox(height: 16),
          _buildTimeField(context, "Time", _timeController),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (_selectedService != null &&
                  _selectedDoctor != null &&
                  _dateController.text.isNotEmpty) {
                final appointment = {
                  "branch": _selectedBranch ?? '',
                  "department": _selectedDepartment ?? '',
                  "service": _selectedService!,
                  "doctor": _selectedDoctor!,
                  "date": _dateController.text,
                  "time": _timeController.text,
                };
                widget.onSubmit(appointment); // Pass data to parent
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please fill all fields."),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text(
              "Confirm Appointment",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        }
      },
    );
  }

  Widget _buildTimeField(
      BuildContext context, String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      readOnly: true,
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          controller.text = pickedTime.format(context);
        }
      },
    );
  }
}
