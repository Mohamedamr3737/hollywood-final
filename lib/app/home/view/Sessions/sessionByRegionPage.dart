import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/session_controller.dart';
import 'session_detail_page.dart';

class SessionListPage extends StatelessWidget {
  final int regionId;
  final String regionName;

  const SessionListPage({super.key, required this.regionId, required this.regionName});

  @override
  Widget build(BuildContext context) {
    final SessionController controller = Get.put(SessionController());
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSessionDetails(regionId);
    });

    return Scaffold(
      body: Column(
        children: [
          // **1️⃣ AppBar at the Top**
          AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              "$regionName Sessions",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),

          // **2️⃣ Stack for Background & Circular Image**
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
                bottom: -50, // Slightly overlapping
                child: Container(
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // **3️⃣ Space Below Circular Image**
          const SizedBox(height: 70),

          // **4️⃣ Expanded Section for Session List**
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                );
              }

              if (controller.sessionDetails.isEmpty) {
                return const Center(child: Text("No sessions found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.sessionDetails.length,
                itemBuilder: (context, index) {
                  var session = controller.sessionDetails[index];
                  bool isCompleted = session["complete"] == "Yes";
                  bool isOnHold = session["status"] == "Hold";
                  bool isUnused = session["complete"] == "No";
                  bool nextSession = session['next_session'] ?? false;

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => SessionDetailPage(session: session));
                    },
                    child: _buildSessionCard(session, isCompleted, isOnHold, isUnused),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isCompleted, bool isOnHold, bool isUnused) {
    String sessionTitle = session["title"] ?? "Unknown Session";
    String sessionDate = session["date"] ?? "Unknown Date";
    String sessionTime = session["time"] ?? "Unknown Time";
    String statusText = 'Status: ' + session['status']??"";
    bool nextSession = session['next_session']??false;
    return Container(
      width: double.infinity, // Full width
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isOnHold ? Colors.red : (isCompleted ? Colors.grey : Colors.orange[300]),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nextSession) // ✅ Shows only if nextSession is true
                  Text(
                    'Next session',
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                Text(
                  sessionTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  "$sessionDate ${_getDayOfWeek(sessionDate)}    $sessionTime",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.black,
              size: 16, // Decrease size (default is 24)
            ),
          ),

        ],
      ),

    );
  }

  String _getDayOfWeek(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      return days[parsedDate.weekday - 1];
    } catch (_) {
      return "";
    }
  }
}
