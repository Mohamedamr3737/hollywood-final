import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/home/controller/AppointmentsController.dart';
import '../consts/colors.dart';

class AppointmentDateTimeSelector extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialTime;
  final String? selectedDepartment;
  final String? selectedDoctor;
  final void Function(DateTime, String) onConfirm;
  final String title;
  final String confirmText;

  const AppointmentDateTimeSelector({
    Key? key,
    required this.onConfirm,
    this.initialDate,
    this.initialTime,
    this.selectedDepartment,
    this.selectedDoctor,
    this.title = '',
    this.confirmText = 'Confirm Appointment',
  }) : super(key: key);

  @override
  State<AppointmentDateTimeSelector> createState() => _AppointmentDateTimeSelectorState();
}

class _AppointmentDateTimeSelectorState extends State<AppointmentDateTimeSelector> {
  final AppointmentsController appointmentsController = Get.find();
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _loading = false;
  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _fetchTimes();
  }

  @override
  void didUpdateWidget(covariant AppointmentDateTimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDepartment != oldWidget.selectedDepartment ||
        widget.selectedDoctor != oldWidget.selectedDoctor ||
        widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      _selectedTime = null;
      _fetchTimes();
    }
  }

  void _fetchTimes() {
    setState(() => _loading = true);
    _availableTimes = [];
    if (_selectedDate != null && widget.selectedDepartment != null && widget.selectedDoctor != null) {
      final department = appointmentsController.settings.firstWhere(
        (dept) => dept['title'] == widget.selectedDepartment,
        orElse: () => {},
      );
      if (department.isNotEmpty) {
        final doctors = List<Map<String, dynamic>>.from(department['doctor'] ?? []);
        final doctor = doctors.firstWhere(
          (doc) => doc['name'] == widget.selectedDoctor,
          orElse: () => {},
        );
        if (doctor.isNotEmpty) {
          final times = List<Map<String, dynamic>>.from(doctor['times'] ?? []);
          _availableTimes = times.map((t) => t['value'].toString()).toList();
        }
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableDates = List<DateTime>.generate(7, (i) => now.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        // Date Selector
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: availableDates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = availableDates[index];
              final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null;
                  });
                  _fetchTimes();
                },
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _monthAbbr(date.month),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        _weekdayAbbr(date.weekday),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Available Times',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12),
        if (_loading)
          Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        if (!_loading)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : const Color(0xFFE1A73B),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        Spacer(),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTime != null)
                  ? () => widget.onConfirm(_selectedDate!, _selectedTime!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                elevation: 2,
              ),
              child: Text(widget.confirmText),
            ),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthAbbr(int month) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month];
  }

  String _weekdayAbbr(int weekday) {
    const days = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday];
  }
} 