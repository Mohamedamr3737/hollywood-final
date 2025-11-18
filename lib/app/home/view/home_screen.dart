import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/app/home/view/Appointments/AppointmentsPage.dart';
import 'package:s_medi/app/home/view/MyBalance/BalancePage.dart';
import 'package:s_medi/app/home/view/MyOrder/MyOrderPage.dart';
import 'package:s_medi/app/home/view/Prescription/PrescriptionPage.dart';
import 'package:s_medi/app/home/view/Profile/ProfilePage.dart';
import 'package:s_medi/app/home/view/SpecialOffers/SpecialOffersPage.dart';
import 'Sessions/MySessionsPage.dart';
import 'package:s_medi/app/home/view/MyData/mydata.dart';
import 'package:s_medi/app/home/view/MyRequests/SelectCategoryRequestPage.dart';
import 'Notifications/NotificationsPage.dart';
import '../controller/notifications_controller.dart';
import '../../auth/controller/token_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NotificationsController _notificationsController = Get.find<NotificationsController>();
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize shine animation with increased duration
    _shineController = AnimationController(
      duration: const Duration(seconds: 6), // Increased from 3 to 6 seconds
      vsync: this,
    );
    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Start repeating shine animation
    _shineController.repeat();

    // Fetch the initial unread count
    checkLoginAndFetchNotifications();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void checkLoginAndFetchNotifications() async {
    if (await getAccessToken() != null) {
      _notificationsController.fetchUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Upper background image
              Image.network(
                'https://t3.ftcdn.net/jpg/03/66/08/34/360_F_366083470_jTuk7ZhaXxlk3paaPIxxPv2jUQhe1tQb.jpg',
                height: screenHeight * 0.25,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Circle profile icon
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
              // Notifications Icon with reactive badge
              Positioned(
                top: 50,
                right: 16,
                child: Obx(() {
                  int count = _notificationsController.unreadCount.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsPage()),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.08),
          // Grid of clickable options
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(screenWidth * 0.04),
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenHeight * 0.03,
              children: [
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTrKVYM6Ttou8JcXZUDH5MJfUpVg4up-jZUUxeHiu-QQpcRtsd7",
                  "My Profile",
                  const ProfilePage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSQyZNKxW9s5lEyrUlJKYIsVKzT4dbuLWHyNIhrO00viFluxBwZ",
                  "My Sessions",
                  const MySessionsPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJvshuC7e14u93nb1z_g4S1kvAIm86R0gQF-Zq4Iwq6-fZL4eY",
                  "Appointments",
                  const AppointmentsPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcT5-LAPHBq67t8jlkeQ3IkUcNbPVuvQvt8R7dQUxqG1eTbKiRJa",
                  "My Balance",
                  MyBalancePage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTE99tUgRwxcKQAWpnqMpWk69e2CvXj0NMIF6Img4DiU3pPsi0X",
                  "Special Offers",
                  const SpecialOffersPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRXi5xyC8STTuAtazhR44tMHwxldphRmj9zzNRtK9X23n-_p93k",
                  "My Order",
                  const MyOrdersPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTusZ1LSpUqvBE3uLFQ3Y9oxEGt8nck4oJRRE3hm5xJEfs9F-An",
                  "Prescription",
                  const PrescriptionPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSRxOq189jhRYvBGI1eN6ONlf2CRKfoGomD4R-0bwruGSkgFcOv",
                  "My Data",
                  const MyDataPage(),
                  screenWidth,
                ),
                _buildGlassOption(
                  context,
                  "https://www.shutterstock.com/shutterstock/videos/3686253711/thumb/12.jpg?ip=x480",
                  "My Requests",
                  const SelectCategoryPage(),
                  screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build each icon option with realistic glass effect and circular animated shine
  Widget _buildGlassOption(
      BuildContext context,
      String imageUrl,
      String label,
      Widget page,
      double screenWidth,
      ) {
    double iconSize = screenWidth * 0.3;
    double fontSize = screenWidth * 0.04;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
                      // Animated circular shine effect
                      AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: _shineAnimation.value * 1.2, // Animate radius from 0 to 1.2
                                colors: [
                                  Colors.white.withOpacity(0.8 * (1 - _shineAnimation.value)), // Fade as it expands
                                  Colors.white.withOpacity(0.6 * (1 - _shineAnimation.value)),
                                  Colors.white.withOpacity(0.3 * (1 - _shineAnimation.value)),
                                  Colors.white.withOpacity(0.1 * (1 - _shineAnimation.value)),
                                  Colors.transparent,
                                ],
                                stops: [
                                  0.0,
                                  0.2,
                                  0.4,
                                  0.7,
                                  1.0,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Static highlight spots for extra realism
                      Positioned(
                        top: iconSize * 0.15,
                        left: iconSize * 0.2,
                        child: Container(
                          width: iconSize * 0.25,
                          height: iconSize * 0.15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Secondary smaller highlight
                      Positioned(
                        top: iconSize * 0.6,
                        right: iconSize * 0.25,
                        child: Container(
                          width: iconSize * 0.15,
                          height: iconSize * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Edge highlight for glass effect
                      Positioned(
                        top: 2,
                        left: 2,
                        right: 2,
                        child: Container(
                          height: iconSize * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
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
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}