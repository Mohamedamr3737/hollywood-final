import '../../../../general/consts/consts.dart';
import '../../controller/session_controller.dart';
import 'get_prepared_page.dart';
import '../../../../general/consts/colors.dart';
import '../../../../general/widgets/DateTimeSlotSelector.dart';

class SessionDetailPage extends StatefulWidget {
  final Map<String, dynamic> session;

  const SessionDetailPage({super.key, required this.session});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late Map<String, dynamic> _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  void showSetTimeDialog(BuildContext context, int sessionId) {
    final SessionController sessionController = Get.find();
    DateTime? selectedDate;
    String? selectedTime;
    int? selectedRoomId;

    // Prepare available dates (next 7 days)
    final now = DateTime.now();
    final availableDates = List<DateTime>.generate(7, (i) => now.add(Duration(days: i)));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              // Get available times for the selected date
              List<String> availableTimes = [];
              if (selectedDate != null) {
                availableTimes = sessionController.availableTimes
                  .map((t) => t['value'] as String)
                  .toList();
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 480,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DateTimeSlotSelector(
                    title: 'Set Session Time',
                    availableDates: availableDates,
                    availableTimes: availableTimes,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: (date) async {
                      setState(() {
                        selectedDate = date;
                        selectedTime = null;
                        selectedRoomId = null;
                      });
                      await sessionController.fetchSessionTimes(sessionId, date.toIso8601String().split('T')[0]);
                      setState(() {});
                    },
                    onTimeSelected: (time) {
                      setState(() {
                        selectedTime = time;
                        // Find the roomId for the selected time
                        final found = sessionController.availableTimes.firstWhere(
                          (t) => t['value'] == time,
                          orElse: () => {},
                        );
                        selectedRoomId = found['room_id'];
                      });
                    },
                    onConfirm: () async {
                      if (selectedDate == null || selectedTime == null || selectedRoomId == null) return;
                      bool ok = await sessionController.setSessionTime(
                        sessionId: sessionId,
                        date: selectedDate!.toIso8601String().split('T')[0],
                        time: selectedTime!,
                        roomId: selectedRoomId!,
                        context: dialogContext,
                      );
                      if (ok) {
                        setState(() {
                          _session['date'] = selectedDate!.toIso8601String().split('T')[0];
                          _session['time'] = selectedTime;
                        });
                        Navigator.pop(dialogContext);
                      }
                    },
                    confirmText: 'Confirm Appointment',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showCancelSessionDialog(BuildContext context, int sessionId) {
    final SessionController sessionController = Get.find();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Session"),
          content: const Text(
            "Are you sure you want to cancel this session? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("No, Keep Session"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                bool success = await sessionController.cancelSessionTime(
                  sessionId: sessionId,
                  context: context,
                );

                if (success) {
                  // Update local session state after canceling
                  setState(() {
                    _session['date'] = "No date provided";
                    _session['time'] = "No time provided";
                  });
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("Yes, Cancel Session"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = _session["complete"] == "Yes";
    String sessionTitle = _session["title"] ?? "Unknown Session";
    String sessionDate = _session["date"];
    String sessionTime = _session["time"];
    String doctorName = _session["doctor"] ?? "";
    String sessionStatus = _session["status"] ?? "Unknown";
    bool isUnused = _session["complete"] == "No";
    String noteBefore = _session["note_before"] ?? "<p>No preparation notes available.</p>";
    String noteAfter = _session["note_after"] ?? "<p>No after session notes available.</p>";
    
    // Check if session has a time set (not the default "No time provided")
    bool hasTimeSet = sessionTime != "No time provided" && sessionTime.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image with overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          image: DecorationImage(
                            image: const NetworkImage(
                              'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.withOpacity(0.8),
                              BlendMode.overlay,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                        title: Text(
                          sessionTitle,
                          style: const TextStyle(
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
                            child: Icon(
                              isCompleted ? Icons.check_circle_outline : Icons.medical_services_outlined,
                              size: 50,
                              color: const Color(0xFF2E7D8F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isCompleted ? 'Session Completed' : 'Session Details',
                            style: const TextStyle(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session Status Card
                      Container(
                        width: double.infinity,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isCompleted ? Colors.green : const Color(0xFF2E7D8F)).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check_circle_outline : Icons.schedule,
                                    color: isCompleted ? Colors.green : const Color(0xFF2E7D8F),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Session Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        isCompleted ? 'Completed' : sessionStatus,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted ? Colors.green : const Color(0xFF2E7D8F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF2E7D8F),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date & Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "$sessionDate ${_getDayOfWeek(sessionDate)} • $sessionTime",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (doctorName.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF2E7D8F),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Doctor',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          doctorName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Action Buttons
                      if (!isCompleted) ...[
                        // Set Time Button (show only if no time is set)
                        if (!hasTimeSet) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => showSetTimeDialog(context, _session["id"]),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D8F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.schedule),
                              label: const Text(
                                'Set Session Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Cancel Session Button (show only if time is set)
                        if (hasTimeSet) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => showCancelSessionDialog(context, _session["id"]),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.cancel),
                              label: const Text(
                                'Cancel Session',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      
                      // Get Prepared Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GetPreparedPage(
                                  htmlContent: noteBefore,
                                  header: 'Preparation Notes',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E7D8F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFF2E7D8F),
                                width: 1,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.info_outline),
                          label: const Text(
                            'Get Prepared',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      if (isCompleted) ...[
                        const SizedBox(height: 12),
                        // After Session Notes Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GetPreparedPage(
                                    htmlContent: noteAfter,
                                    header: 'After Session Notes',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.notes),
                            label: const Text(
                              'View Session Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);

      // In Dart, Sunday = 7, Monday = 1, ... so let's map properly:
      List<String> days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ];
      return days[parsedDate.weekday - 1];
    } catch (_) {
      return "";
    }
  }
}
