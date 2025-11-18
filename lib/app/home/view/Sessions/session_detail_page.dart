import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../general/consts/consts.dart';
import '../../../../general/services/alert_service.dart';
import '../../controller/session_controller.dart';
import 'get_prepared_page.dart';

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
    showDialog(
      context: context,
      builder: (context) {
        String? selectedDate;
        String? selectedTime;
        int? selectedRoomId;
        DateTime? selectedDateTime;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Auto-select today's date and fetch its times on first build
            if (selectedDate == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                DateTime today = DateTime.now();
                String todayFormatted = today.toLocal().toString().split(' ')[0];

                SessionController sessionController = Get.find();
                await sessionController.fetchAvailableTimes(sessionId, todayFormatted);

                setDialogState(() {
                  selectedDate = todayFormatted;
                  selectedDateTime = today;
                });
              });
            }
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.orange),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Set Time",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Calendar Widget
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildInfiniteCalendarWidget(setDialogState, selectedDateTime, (String date, DateTime dateTime) {
                              setDialogState(() {
                                selectedDate = date;
                                selectedDateTime = dateTime;
                                // Reset time selection when date changes
                                selectedTime = null;
                                selectedRoomId = null;
                              });
                            }),
                            const SizedBox(height: 30),

                            // Available Times Section
                            if (selectedDate != null) ...[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Available Times",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTimeSelectionGrid(setDialogState, sessionId, selectedDate!, selectedTime, (String time, int roomId) {
                                setDialogState(() {
                                  selectedTime = time;
                                  selectedRoomId = roomId;
                                });
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Confirm Button
                    if (selectedDate != null && selectedTime != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedDate == null || selectedTime == null || selectedRoomId == null) {
                              AlertService.selectDateTime(context);
                              return;
                            }

                            SessionController sessionController = Get.find();
                            bool ok = await sessionController.setSessionTime(
                              sessionId: sessionId,
                              date: selectedDate!,
                              time: selectedTime!,
                              roomId: selectedRoomId!,
                              context: context,
                            );

                            // Update local session state after setting time
                            if (ok) {
                              // Close dialog first
                              Navigator.pop(context);
                              // Update the main page state
                              this.setState(() {
                                _session['date'] = selectedDate!;
                                _session['time'] = selectedTime!;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Confirm Appointment",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Refresh the main page when dialog closes
      setState(() {});
    });
  }

  Widget _buildInfiniteCalendarWidget(StateSetter setDialogState, DateTime? selectedDateTime, Function(String, DateTime) onDateSelected) {
    DateTime now = DateTime.now();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: null, // Infinite scroll
        itemBuilder: (context, index) {
          DateTime date = now.add(Duration(days: index));
          bool isSelected = selectedDateTime != null &&
              date.year == selectedDateTime.year &&
              date.month == selectedDateTime.month &&
              date.day == selectedDateTime.day;
          String month = _getMonthAbbr(date.month);
          String day = date.day.toString();
          String weekday = _getWeekdayAbbr(date.weekday);

          return GestureDetector(
            onTap: () async {
              String formattedDate = date.toLocal().toString().split(' ')[0];

              // Fetch available times for the selected date
              SessionController sessionController = Get.find();
              await sessionController.fetchAvailableTimes(widget.session['id'], formattedDate);

              // Call the callback to update selected date
              onDateSelected(formattedDate, date);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weekday,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelectionGrid(StateSetter setDialogState, int sessionId, String selectedDate, String? selectedTime, Function(String, int) onTimeSelected) {
    return Obx(() {
      SessionController sessionController = Get.find();

      if (sessionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (sessionController.availableTimes.isEmpty) {
        return const Text(
          "No available times for this date",
          style: TextStyle(color: Colors.grey),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
        ),
        itemCount: sessionController.availableTimes.length,
        itemBuilder: (context, index) {
          var timeSlot = sessionController.availableTimes[index];
          String time = timeSlot["time"] ?? "No time";
          int roomId = timeSlot["room_id"] ?? 0;
          bool isSelected = selectedTime == time;

          return GestureDetector(
            onTap: () {
              // Call the callback to set selected time and room
              onTimeSelected(time, roomId);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.orange,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.orange : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _showConfirmTimeDialog(BuildContext context, int sessionId, String date, String time, int roomId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.orange),
                      onPressed: () {
                        Navigator.pop(context);
                        showSetTimeDialog(context, sessionId);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "clatuu alpha",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),

                // Selected time display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Selected Time",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$date ${_getDayOfWeek(date)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      SessionController sessionController = Get.find();
                      bool ok = await sessionController.setSessionTime(
                        sessionId: sessionId,
                        date: date,
                        time: time,
                        roomId: roomId,
                        context: context,
                      );

                      if (ok) {
                        setState(() {
                          _session['date'] = date;
                          _session['time'] = time;
                        });
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirm Appointment",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    return months[month - 1];
  }

  String _getWeekdayAbbr(int weekday) {
    const weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    return weekdays[weekday - 1];
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Session Details",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.network(
                'https://t3.ftcdn.net/jpg/03/66/08/34/360_F_366083470_jTuk7ZhaXxlk3paaPIxxPv2jUQhe1tQb.jpg',
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: -50,
                child: Container(
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 70),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- SESSION HEADER ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.grey : Colors.orange[300],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sessionTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              isUnused ? "unused" : "used",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$sessionDate ${_getDayOfWeek(sessionDate)}    $sessionTime",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- SESSION INFO ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCompleted) ...[
                          const Text(
                            "Status",
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            sessionStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            "Doctor",
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- BUTTONS ---
                  if (isCompleted)
                  // If session is done, show "After Session Notes" only
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GetPreparedPage(
                              htmlContent: noteAfter,
                              header: 'After session notes',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "After Session Notes",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else
                  // Session is NOT completed
                    Column(
                      children: [
                        // --- SET or RESET TIME ---
                        ElevatedButton(
                          onPressed: () async {
                            final SessionController sessionController = Get.find();

                            // If there's no time or it's on hold, we set time
                            if (_session["time"].toString() == 'No time provided' ||
                                _session["time"].toString().isEmpty ||
                                _session["date"].toString() == 'No date provided' ||
                                _session["date"].toString().isEmpty ||
                                _session["status"] == "Hold") {
                              showSetTimeDialog(context, _session['id']);
                            } else {
                              final SessionController sessionController = Get.find();

                              // Wait for the method to return
                              bool isSuccess = await sessionController.cancelSessionTime(
                                sessionId: _session['id'],
                                context: context,
                              );

                              // Only update local state if the API call was successful
                              if (isSuccess) {
                                setState(() {
                                  _session["date"] = "No date provided";
                                  _session["time"] = "No time provided";
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            (_session["time"] == 'No time provided' ||
                                _session["time"].toString().isEmpty ||
                                _session["date"] == 'No date provided' ||
                                _session["date"].toString().isEmpty ||
                                _session["status"] == "Hold")
                                ? "Set Time"
                                : "Reset Time",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- CANCEL SESSION ---
                        ElevatedButton(
                          onPressed: () async {
                            final SessionController sessionController = Get.find();

                            // Wait for the method to return
                            bool isSuccess = await sessionController.cancelSessionTime(
                              sessionId: _session['id'],
                              context: context,
                            );


                            // Only update local state if the API call was successful
                            if (isSuccess) {
                              setState(() {
                                _session["date"] = "No date provided";
                                _session["time"] = "No time provided";
                              });
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel Session",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- GET PREPARED ---
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GetPreparedPage(
                                  htmlContent: noteBefore,
                                  header: 'Preparation notes',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Get Prepared",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
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