import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/home/controller/session_controller.dart';
import '../consts/colors.dart';

class SessionDateTimeSelector extends StatefulWidget {
  final int sessionId;
  final DateTime? initialDate;
  final String? initialTime;
  final void Function(DateTime, String, int) onConfirm;
  final String title;
  final String confirmText;

  const SessionDateTimeSelector({
    Key? key,
    required this.sessionId,
    required this.onConfirm,
    this.initialDate,
    this.initialTime,
    this.title = '',
    this.confirmText = 'Confirm Appointment',
  }) : super(key: key);

  @override
  State<SessionDateTimeSelector> createState() => _SessionDateTimeSelectorState();
}

class _SessionDateTimeSelectorState extends State<SessionDateTimeSelector> {
  final SessionController sessionController = Get.find();
  DateTime? _selectedDate;
  String? _selectedTime;
  int? _selectedRoomId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    if (_selectedDate != null) {
      _fetchTimes(_selectedDate!);
    }
  }

  Future<void> _fetchTimes(DateTime date) async {
    setState(() => _loading = true);
    await sessionController.fetchSessionTimes(widget.sessionId, date.toIso8601String().split('T')[0]);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableDates = List<DateTime>.generate(7, (i) => now.add(Duration(days: i)));
    final availableTimes = _selectedDate != null
        ? sessionController.availableTimes
        : [];

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
                onTap: () async {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null;
                    _selectedRoomId = null;
                  });
                  await _fetchTimes(date);
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
              children: availableTimes.map<Widget>((timeData) {
                final time = timeData['value'] as String;
                final roomId = timeData['room_id'] as int;
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                      _selectedRoomId = roomId;
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
              onPressed: (_selectedDate != null && _selectedTime != null && _selectedRoomId != null)
                  ? () => widget.onConfirm(_selectedDate!, _selectedTime!, _selectedRoomId!)
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