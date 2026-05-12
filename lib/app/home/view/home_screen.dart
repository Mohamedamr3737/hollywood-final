import 'dart:async';
import 'dart:ui';

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
import 'package:s_medi/app/home/view/Shop/ShopView.dart';
import '../controller/notifications_controller.dart';
import '../controller/home_ads_controller.dart';
import '../../auth/controller/token_controller.dart';
import '../../../general/consts/consts.dart';
import 'package:s_medi/serv/ServicesPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NotificationsController _notificationsController = Get.find<NotificationsController>();
  final HomeAdsController _adsController = Get.put(HomeAdsController());
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;
  late final PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
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
    _adsController.fetchAds().then((_) => _startBannerAutoScroll());

  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void checkLoginAndFetchNotifications() async {
    if (await getAccessToken() != null) {
      _notificationsController.fetchUnreadCount();
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerPageController.hasClients || _adsController.ads.isEmpty) return;
      final nextPage = (_currentBannerIndex + 1) % _adsController.ads.length;
      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleBannerTap(HomeAd ad) {
    Widget destination;
    switch (ad.type.toLowerCase()) {
      case 'product':
        destination = const ProductsPage();
        break;
      case 'offer':
        destination = const SpecialOffersPage();
        break;
      case 'page':
        destination = const ServicesPage();
        break;
      default:
        destination = const SpecialOffersPage();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          _buildHeaderSection(screenWidth, screenHeight),
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

  Widget _buildHeaderSection(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.32,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: _buildBannerCarousel(screenHeight),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: Obx(() {
                int count = _notificationsController.unreadCount.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: IconButton(
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
                    ),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
          ],
        ),
      ),
    );
  }
  Widget _buildBannerCarousel(double screenHeight) {
    return Obx(() {
      if (_adsController.isLoading.value) {
        return _buildBannerPlaceholder(screenHeight);
      }

      if (_adsController.ads.isEmpty) {
        if (_adsController.errorMessage.isNotEmpty) {
          return _buildBannerError(screenHeight, _adsController.errorMessage.value);
        }
        return SizedBox(
          height: screenHeight * 0.25,
          width: double.infinity,
          child: Image.network(
            AppAssets.placeholderImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              );
            },
          ),
        );
      }

      return GestureDetector(
        onTap: () => _handleBannerTap(_adsController.ads[_currentBannerIndex]),
        child: SizedBox(
          height: screenHeight * 0.25,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Animated PageView for images
              PageView.builder(
                controller: _bannerPageController,
                itemCount: _adsController.ads.length,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ad = _adsController.ads[index];
                  return SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      ad.imageUrl.isNotEmpty ? ad.imageUrl : AppAssets.placeholderImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  );
                },
              ),
              // Gradient overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Ad name text in a modern glassmorphism pill
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          _adsController.ads[_currentBannerIndex].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Centered dots indicator at the bottom
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: _buildBannerIndicators(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBannerPlaceholder(double screenHeight) {
    return Container(
      height: screenHeight * 0.25,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBannerError(double screenHeight, String message) {
    return Container(
      height: screenHeight * 0.25,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Obx(() {
      final total = _adsController.ads.length;
      if (total <= 1) return const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          final isActive = _currentBannerIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 26 : 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      );
    });
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