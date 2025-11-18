// ignore_for_file: use_key_in_widget_constructors, unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/about/about.dart';
import 'package:s_medi/app/home/view/Shop/ShopView.dart';
import 'package:s_medi/app/home/view/home_screen.dart';
import 'package:s_medi/general/consts/colors.dart';
import 'package:s_medi/serv/servicespage.dart';
import 'Sessions/MySessionsPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int selectedIndex = 2; // Default to "Home" tab
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define the list of screens
  final List<Widget> screenList = [
    ServicesPage(),       // Services page
    AboutPage(),          // About page
    const HomePage(),     // Main home screen widget
    const ProductsPage(), // Shop page
    const MySessionsPage(), // My Sessions page
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screenList,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFFFFB74D), // iOS blue
                  unselectedItemColor: Colors.black.withOpacity(0.6),
                  showUnselectedLabels: true,
                  currentIndex: selectedIndex,
                  onTap: onItemTapped,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(selectedIndex == 0 ? 8 : 4),
                        decoration: selectedIndex == 0
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.group,
                          size: selectedIndex == 0 ? 26 : 24,
                        ),
                      ),
                      label: "Services",
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(selectedIndex == 1 ? 8 : 4),
                        decoration: selectedIndex == 1
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.info_outline,
                          size: selectedIndex == 1 ? 26 : 24,
                        ),
                      ),
                      label: "About",
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: selectedIndex == 2 ? _scaleAnimation.value : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(selectedIndex == 2 ? 8 : 4),
                              decoration: selectedIndex == 2
                                  ? BoxDecoration(
                                color: const Color(0xFF007AFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              )
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps",
                                  width: selectedIndex == 2 ? 30 : 28,
                                  height: selectedIndex == 2 ? 30 : 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(selectedIndex == 3 ? 8 : 4),
                        decoration: selectedIndex == 3
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: selectedIndex == 3 ? 26 : 24,
                        ),
                      ),
                      label: "Shop",
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(selectedIndex == 4 ? 8 : 4),
                        decoration: selectedIndex == 4
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.event_note_outlined,
                          size: selectedIndex == 4 ? 26 : 24,
                        ),
                      ),
                      label: "My Sessions",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}