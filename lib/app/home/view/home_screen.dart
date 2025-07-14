import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/home/view/Appointments/AppointmentsPage.dart';
import '/app/home/view/MyBalance/BalancePage.dart';
import '/app/home/view/MyOrder/MyOrderPage.dart';
import '/app/home/view/Prescription/PrescriptionPage.dart';
import '/app/home/view/Profile/ProfilePage.dart';
import '/app/home/view/SpecialOffers/SpecialOffersPage.dart';
import 'Sessions/MySessionsPage.dart';
import '/app/home/view/MyData/mydata.dart';
import '/app/home/view/MyRequests/SelectCategoryRequestPage.dart';
import 'Notifications/NotificationsPage.dart';
import '../controller/notifications_controller.dart';
import '../../auth/controller/token_controller.dart';
import '../../../general/consts/colors.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NotificationsController _notificationsController = Get.find<NotificationsController>();
  late AnimationController _iconBurstController;
  late AnimationController _iconFlowController;
  late AnimationController _logoMoveController;
  late AnimationController _fadeInController;
  late Animation<double> _fadeAnimation;
  bool _logoAtHeader = false;
  bool _burstComplete = false;

  final String logoUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps";
  // Replace with a much larger, more diverse set of icons representing body/beauty/medical concepts
  final List<IconData> beautyIcons = [
    Icons.face,
    Icons.face_6,
    Icons.face_3,
    Icons.face_retouching_natural,
    Icons.mood,
    Icons.emoji_emotions,
    Icons.emoji_nature,
    Icons.emoji_people,
    Icons.emoji_symbols,
    Icons.favorite,
    Icons.favorite_border,
    Icons.spa,
    Icons.healing,
    Icons.masks,
    Icons.waves,
    Icons.accessibility_new, // body
    Icons.accessibility,
    Icons.accessible_forward, // legs
    Icons.directions_walk, // legs
    Icons.directions_run, // legs
    Icons.fitness_center, // body
    Icons.sports_gymnastics, // body
    Icons.sports_mma, // arm
    Icons.pan_tool_alt, // hand/arm
    Icons.back_hand, // hand
    Icons.cut, // hair (scissors)
    Icons.content_cut, // hair (scissors)
    Icons.sanitizer, // medical
    Icons.medical_services, // syringe/medical
    Icons.vaccines, // syringe
    Icons.healing, // medical
    Icons.wc, // body
    Icons.boy,
    Icons.girl,
    Icons.woman,
    Icons.man,
    Icons.transgender,
    Icons.baby_changing_station,
    Icons.hiking,
    Icons.hail,
    Icons.spa,
    Icons.sick,
    Icons.psychology,
    Icons.self_improvement,
    Icons.stroller,
    Icons.sports_handball,
    Icons.sports_kabaddi,
    Icons.sports_martial_arts,
    Icons.sports,
    Icons.sports_volleyball,
    Icons.sports_basketball,
    Icons.sports_soccer,
    Icons.sports_tennis,
    Icons.sports_rugby,
    Icons.sports_cricket,
    Icons.sports_football,
    Icons.sports_golf,
    Icons.sports_hockey,
    Icons.sports_motorsports,
    Icons.sports_volleyball,
    Icons.sports,
    // Add more if needed
  ];
  // We'll use 40+ icons by repeating the list if needed
  static const int numBackgroundIcons = 48;
  late List<_IconPathParams> _iconPathParams;

  @override
  void initState() {
    super.initState();
    _iconBurstController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _iconFlowController = AnimationController(
      duration: const Duration(seconds: 28),
      vsync: this,
    );
    _logoMoveController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeInOut),
    );
    _iconPathParams = List.generate(numBackgroundIcons, (i) => _IconPathParams.random(i));
    checkLoginAndFetchNotifications();
    // Start burst, then flow, then logo move
    Future.delayed(const Duration(milliseconds: 200), () {
      _iconBurstController.forward().then((_) {
        setState(() => _burstComplete = true);
        _iconFlowController.repeat();
        setState(() {
          _logoAtHeader = true;
        });
        _logoMoveController.forward();
        // Fade in header/content after logo lands
        Future.delayed(const Duration(milliseconds: 900), () {
          _fadeInController.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _iconBurstController.dispose();
    _iconFlowController.dispose();
    _logoMoveController.dispose();
    _fadeInController.dispose();
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
    final double logoStartSize = screenWidth * 0.32;
    final double logoEndSize = screenWidth * 0.22;
    final double iconFlowRadius = screenWidth * 0.44;
    final double headerHeight = 180.0;
    // Alignment for logo: center to header
    final Alignment logoStart = Alignment.center;
    final Alignment logoEnd = Alignment(0, -0.65); // just below header text, lower than before

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Glassmorphism background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0E21),
                  const Color(0xFF1A237E),
                  const Color(0xFF0A0E21),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Flowing faded icons in the background
          AnimatedBuilder(
            animation: _burstComplete ? _iconFlowController : _iconBurstController,
            builder: (context, child) {
              final double t = _burstComplete ? _iconFlowController.value : _iconBurstController.value;
              final double screenWidth = MediaQuery.of(context).size.width;
              final double screenHeight = MediaQuery.of(context).size.height;
              final double iconBurstRadius = math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight) * 0.5;
              final double logoCenterX = screenWidth / 2;
              final double logoCenterY = screenHeight / 2;
              return Stack(
                children: [
                  for (int i = 0; i < numBackgroundIcons; i++)
                    Builder(builder: (context) {
                      Offset pos;
                      if (!_burstComplete) {
                        // Burst: from logo center to burst radius in a unique direction
                        final double angle = i * 2 * math.pi / numBackgroundIcons + 0.2 * i;
                        final double r = Curves.easeOut.transform(t) * iconBurstRadius;
                        pos = Offset(
                          logoCenterX + r * math.cos(angle),
                          logoCenterY + r * math.sin(angle),
                        );
                      } else {
                        // Flow: follow a unique, looping path that covers the whole screen
                        final _IconPathParams params = _iconPathParams[i];
                        final double tt = (t + params.phase) % 1.0;
                        // Lissajous-like path, but scaled to cover the whole screen
                        final double x = screenWidth / 2 + (screenWidth * 0.55) * math.sin(params.a * tt * 2 * math.pi + params.offsetX);
                        final double y = screenHeight / 2 + (screenHeight * 0.45) * math.sin(params.b * tt * 2 * math.pi + params.offsetY);
                        pos = Offset(x, y);
                      }
                      final icon = beautyIcons[i % beautyIcons.length];
                      return Positioned(
                        left: pos.dx - 24,
                        top: pos.dy - 24,
                        child: Opacity(
                          opacity: 0.13,
                          child: Icon(
                            icon,
                            color: i % 3 == 0 ? Colors.orangeAccent : Colors.blue[900],
                            size: 48,
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
          // Animated logo: moves from center to header and shrinks
          AnimatedAlign(
            alignment: _logoAtHeader ? logoEnd : logoStart,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutCubic,
            child: AnimatedBuilder(
              animation: _logoMoveController,
              builder: (context, child) {
                final double t = _logoMoveController.value;
                final double size = logoStartSize + (logoEndSize - logoStartSize) * t;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          // Header text and welcome text (fade in after logo lands)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 24,
                        left: 0,
                        right: 0,
                        child: const Text(
                          'Hollywood Clinic',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Main content (fade in)
          Positioned.fill(
            top: 60 + headerHeight + 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildServiceCard(
                            context,
                            "My Profile",
                            Icons.person_outline,
                            Colors.orangeAccent,
                            const ProfilePage(),
                          ),
                          _buildServiceCard(
                            context,
                            "My Sessions",
                            Icons.video_call_outlined,
                            Colors.orangeAccent,
                            const MySessionsPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "Appointments",
                            Icons.calendar_today_outlined,
                            Colors.orangeAccent,
                            const AppointmentsPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "My Balance",
                            Icons.account_balance_wallet_outlined,
                            Colors.orangeAccent,
                            MyBalancePage(),
                          ),
                          _buildServiceCard(
                            context,
                            "Special Offers",
                            Icons.local_offer_outlined,
                            Colors.orangeAccent,
                            const SpecialOffersPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "My Orders",
                            Icons.shopping_bag_outlined,
                            Colors.orangeAccent,
                            const MyOrdersPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "Prescription",
                            Icons.medical_services_outlined,
                            Colors.orangeAccent,
                            const PrescriptionPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "My Data",
                            Icons.folder_outlined,
                            Colors.orangeAccent,
                            const MyDataPage(),
                          ),
                          _buildServiceCard(
                            context,
                            "My Requests",
                            Icons.support_agent_outlined,
                            Colors.orangeAccent,
                            const SelectCategoryPage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Notifications Icon (top right, always visible)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 24),
              child: Obx(() {
                int count = _notificationsController.unreadCount.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
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
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
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
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.22),
              color.withOpacity(0.10),
              Colors.white.withOpacity(0.13),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.22),
            width: 1.8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glass inner layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.10),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // Add a subtle blur for glass effect
                  backgroundBlendMode: BlendMode.overlay,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.18),
                        Colors.white.withOpacity(0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.32),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: color.withOpacity(0.22),
                      width: 2.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 36,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                // Optional: Add a subtitle/description for each card
                // const SizedBox(height: 6),
                // Text(
                //   'Description here',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: color.withOpacity(0.7),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for unique icon flow paths
class _IconPathParams {
  final double a, b, phase, offsetX, offsetY;
  _IconPathParams(this.a, this.b, this.phase, this.offsetX, this.offsetY);
  factory _IconPathParams.random(int seed) {
    final math.Random rand = math.Random(seed * 17 + 42);
    return _IconPathParams(
      1.0 + rand.nextDouble() * 1.5, // a
      1.0 + rand.nextDouble() * 1.5, // b
      rand.nextDouble(), // phase
      rand.nextDouble() * 2 * math.pi, // offsetX
      rand.nextDouble() * 2 * math.pi, // offsetY
    );
  }
}
