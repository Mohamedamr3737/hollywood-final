// lib/app/main/view/main_page.dart

// ignore_for_file: unused_import, file_names, library_private_types_in_public_api, prefer_const_constructors

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:s_medi/about/about.dart';
import 'package:s_medi/app/home/view/Shop/ShopView.dart';
import 'package:s_medi/app/home/view/home_screen.dart';
import 'package:s_medi/serv/servicespage.dart';
import 'package:s_medi/app/home/view/home.dart';
import 'package:s_medi/app/home/view/Sessions/MySessionsPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 2; // Default to "Home" tab
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // List of pages for each tab
  final List<Widget> _pages = [
    ServicesPage(),
    AboutPage(),
    HomePage(), // Replace with your Home page widget
    ProductsPage(), // Replace with your Shop page widget
    MySessionsPage(), // Use the prefix 'auth' to specify the correct MySessionsPage
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

  // Update the selected index and rebuild with setState
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
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
                  selectedItemColor: const Color(0xFFFFB74D) // same as Colors.orange[300]
                  ,
                  unselectedItemColor: Colors.black.withOpacity(0.6),
                  showUnselectedLabels: true,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
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
                        padding: EdgeInsets.all(_selectedIndex == 0 ? 8 : 4),
                        decoration: _selectedIndex == 0
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.group,
                          size: _selectedIndex == 0 ? 26 : 24,
                        ),
                      ),
                      label: 'Services',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(_selectedIndex == 1 ? 8 : 4),
                        decoration: _selectedIndex == 1
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.info_outline,
                          size: _selectedIndex == 1 ? 26 : 24,
                        ),
                      ),
                      label: 'About',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _selectedIndex == 2 ? _scaleAnimation.value : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(_selectedIndex == 2 ? 8 : 4),
                              decoration: _selectedIndex == 2
                                  ? BoxDecoration(
                                color: const Color(0xFF007AFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              )
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps",
                                  width: _selectedIndex == 2 ? 30 : 28,
                                  height: _selectedIndex == 2 ? 30 : 28,
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
                        padding: EdgeInsets.all(_selectedIndex == 3 ? 8 : 4),
                        decoration: _selectedIndex == 3
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: _selectedIndex == 3 ? 26 : 24,
                        ),
                      ),
                      label: 'Shop',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(_selectedIndex == 4 ? 8 : 4),
                        decoration: _selectedIndex == 4
                            ? BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          Icons.event_note_outlined,
                          size: _selectedIndex == 4 ? 26 : 24,
                        ),
                      ),
                      label: 'My Sessions',
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