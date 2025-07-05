import 'package:flutter/material.dart';
import 'package:s_medi/about/about.dart';
import 'package:s_medi/app/home/view/Shop/ShopView.dart';
import 'package:s_medi/app/home/view/home_screen.dart';
import 'package:s_medi/serv/servicespage.dart';
import 'package:s_medi/app/home/view/home.dart';
import 'package:s_medi/app/home/view/Sessions/MySessionsPage.dart';
import 'package:s_medi/general/consts/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // Default to "Home" tab

  // List of pages for each tab
  final List<Widget> _pages = [
    ServicesPage(),
    AboutPage(),
    HomePage(),
    ProductsPage(),
    MySessionsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          _getPageTitle(_selectedIndex),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surfaceColor,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textLight,
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
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: _selectedIndex == 0 ? 26 : 24,
                  ),
                ),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: _selectedIndex == 1 ? 26 : 24,
                  ),
                ),
                label: 'About',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: _selectedIndex == 2 ? 32 : 28,
                    height: _selectedIndex == 2 ? 32 : 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps",
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: _selectedIndex == 3 ? 26 : 24,
                  ),
                ),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.video_call_outlined,
                    size: _selectedIndex == 4 ? 26 : 24,
                  ),
                ),
                label: 'Sessions',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Services';
      case 1:
        return 'About Us';
      case 2:
        return 'Hollywood Clinic';
      case 3:
        return 'Shop';
      case 4:
        return 'My Sessions';
      default:
        return 'Hollywood Clinic';
    }
  }
}
