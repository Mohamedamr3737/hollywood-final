// ignore_for_file: use_key_in_widget_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/about/about.dart';
import '/app/home/view/Shop/ShopView.dart';
import '/app/home/view/home_screen.dart';
import '/general/consts/colors.dart';
import '/serv/servicespage.dart';
import 'Sessions/MySessionsPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 2; // Default to "Home" tab

  // Define the list of screens
  final List<Widget> screenList = [
    ServicesPage(),       // Services page
    AboutPage(),          // About page
    const HomePage(),     // Main home screen widget
    const ProductsPage(), // Shop page
    const MySessionsPage(), // My Sessions page
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList[selectedIndex],
      // Wrap the BottomNavigationBar in a Container to achieve a rounded, white bar with a shadow.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16.0), // Rounded top corners
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          // Both selected and unselected icons will be black in this style.
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Services",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: "About",
            ),
            BottomNavigationBarItem(
              // Replaces the icon with a network image for "Home"
              icon: Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps",
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Shop",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: "My Sessions",
            ),
          ],
        ),
      ),
    );
  }
}
