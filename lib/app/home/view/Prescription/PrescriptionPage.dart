// prescription_flow.dart
import 'package:flutter/material.dart';
import 'MedicationTab.dart';
import 'DietTab.dart';
import '../../../auth/controller/token_controller.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // We'll replicate your background + AppBar + 2 tabs style
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // (A) Background image at top
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 150,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // (B) AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "My Prescriptions",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (C) Circular lotus icon
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: Container(
              width: 140,
              height: 140,
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
            )

          ),
          // (D) Tab bar (Diet, Medication) with tab views
          Positioned.fill(
            top: 240,
            child: Column(
              children: [
                _buildCustomTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      DietTab(),        // shows diet prescriptions
                      MedicationTab(),  // shows medication prescriptions
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A custom tab bar that matches your style
  Widget _buildCustomTabBar() {
    return Container(
      color: const Color(0xFF000610),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>setState(() {
                _tabController.index = 0;
              }) ,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: _tabController.index == 0 ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Diet",
                  style: TextStyle(
                    color: _tabController.index == 0 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>setState(() {
                _tabController.index = 1;
              }) ,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: _tabController.index == 1 ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Medication",
                  style: TextStyle(
                    color: _tabController.index == 1 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
