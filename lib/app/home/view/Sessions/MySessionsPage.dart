import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../controller/session_controller.dart';
import 'sessionByRegionPage.dart';
import '../../../auth/controller/token_controller.dart';

class MySessionsPage extends StatelessWidget {
  const MySessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized properly
    checkLoginStatus();
    final SessionController sessionController = Get.put(SessionController());

    // Explicitly call fetchSessions() in case onInit is not called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionController.fetchSessions();
    });

    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    Widget _buildSessionOption(BuildContext context, String imageUrl,
        String label, double screenWidth, int regionId) {
      double iconSize = screenWidth * 0.3;
      double fontSize = screenWidth * 0.04;

      return GestureDetector(
        onTap: () {
          Get.to(() => SessionListPage(regionId: regionId, regionName: label));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                // Main glass container
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    // Enhanced shadow for depth
                    boxShadow: [
                      // Deep shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                        spreadRadius: 2,
                      ),
                      // Medium shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                      // Subtle inner glow
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Glass overlay with realistic effects
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // Multi-layer glass effect
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.4), // Top highlight
                                Colors.white.withOpacity(0.1), // Mid transparency
                                Colors.white.withOpacity(0.05), // Bottom subtle
                                Colors.black.withOpacity(0.1), // Bottom depth
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                            // Glass border
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Static highlight spots for extra realism
                        Positioned(
                          top: iconSize * 0.15,
                          left: iconSize * 0.2,
                          child: Container(
                            width: iconSize * 0.1,
                            height: iconSize * 0.1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        // Secondary highlight
                        Positioned(
                          top: iconSize * 0.3,
                          right: iconSize * 0.15,
                          child: Container(
                            width: iconSize * 0.15,
                            height: iconSize * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
            title: const Text(
              "My Sessions",
              style: TextStyle(
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
                height: screenHeight * 0.25,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: -screenHeight * 0.06,
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

          // **3️⃣ Space Below Circular Image to Prevent Overlap**
          const SizedBox(height: 50),

          // **4️⃣ Expanded Section for the Session List**
          Expanded(
            child: Obx(() {
              if (sessionController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (sessionController.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    sessionController.errorMessage.value,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              }

              if (sessionController.regions.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "No Sessions Available",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenHeight * 0.03,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: sessionController.regions
                      .map((session) => _buildSessionOption(
                    context,
                    session["icon"] ?? "",
                    session["title"] ?? "",
                    screenWidth,
                    session['id'] ?? "",
                  ))
                      .toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );

  }
}