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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NotificationsController _notificationsController = Get.find<NotificationsController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    checkLoginAndFetchNotifications();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      backgroundColor: AppColors.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              height: screenHeight * 0.35,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
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
                  
                  // Notifications Icon
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Obx(() {
                      int count = _notificationsController.unreadCount.value;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
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
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
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
                        ),
                      );
                    }),
                  ),
                  
                  // Welcome Text and Profile
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Hollywood Clinic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Your health journey starts here',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Services Grid
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
                      AppColors.primaryColor,
                      const ProfilePage(),
                    ),
                    _buildServiceCard(
                      context,
                      "My Sessions",
                      Icons.video_call_outlined,
                      AppColors.accentColor,
                      const MySessionsPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "Appointments",
                      Icons.calendar_today_outlined,
                      AppColors.infoColor,
                      const AppointmentsPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "My Balance",
                      Icons.account_balance_wallet_outlined,
                      AppColors.successColor,
                      MyBalancePage(),
                    ),
                    _buildServiceCard(
                      context,
                      "Special Offers",
                      Icons.local_offer_outlined,
                      AppColors.warningColor,
                      const SpecialOffersPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "My Orders",
                      Icons.shopping_bag_outlined,
                      AppColors.primaryDark,
                      const MyOrdersPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "Prescription",
                      Icons.medical_services_outlined,
                      AppColors.errorColor,
                      const PrescriptionPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "My Data",
                      Icons.folder_outlined,
                      AppColors.textSecondary,
                      const MyDataPage(),
                    ),
                    _buildServiceCard(
                      context,
                      "My Requests",
                      Icons.support_agent_outlined,
                      AppColors.accentLight,
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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
