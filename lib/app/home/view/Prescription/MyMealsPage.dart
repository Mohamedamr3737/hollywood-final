import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/diet_controller.dart';
import '../../../../general/consts/colors.dart';

class MyMealsPage extends StatefulWidget {
  final int dayNum;   // The selected day (e.g. 1, 2, 3, etc.)
  final int dietId;   // The current diet ID

  // Make sure you pass both dayNum and dietId when navigating:
  // Navigator.of(context).push(MaterialPageRoute(
  //   builder: (_) => MyMealsPage(dayNum: 1, dietId: 210),
  // ));
  const MyMealsPage({Key? key, required this.dayNum, required this.dietId})
      : super(key: key);

  @override
  State<MyMealsPage> createState() => _MyMealsPageState();
}

class _MyMealsPageState extends State<MyMealsPage> with SingleTickerProviderStateMixin {
  late DietController _dietController;
  late TabController _tabController;

  // We'll store the list of diet times (e.g. Breakfast, Lunch, etc.)
  // Each item might look like: { "id": 1, "title": "Breakfast" }
  List<Map<String, dynamic>> _dietTimes = [];

  // Flag to indicate if we're still loading the times
  bool _isLoadingTabs = true;

  @override
  void initState() {
    super.initState();
    _dietController = DietController();
    _fetchDietTimes();
  }

  // Fetch the list of diet times from the API
  Future<void> _fetchDietTimes() async {
    try {
      final timesList = await _dietController.fetchDietTimes();
      // Convert each item into a Map<String, dynamic>
      // e.g. {"id":1,"title":"Breakfast"}
      _dietTimes = timesList
          .map((item) => {
        'id': item['id'],
        'title': item['title'],
      })
          .toList();

      // Create the TabController with the number of times we have
      _tabController = TabController(length: _dietTimes.length, vsync: this);

      setState(() {
        _isLoadingTabs = false;
      });
    } catch (e) {
      // Handle or log error as needed
      debugPrint("Error fetching diet times: $e");
      setState(() {
        _dietTimes = [];
        _isLoadingTabs = false;
      });
    }
  }

  // For "Set A Reminder" we just show a demo time picker
  void _setReminder() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set at ${pickedTime.format(context)}")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Build the TabBar (sub-tabs) using the dietTimes from the API
  Widget _buildMealsTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF2E7D8F),
              width: 3,
            ),
          ),
        ),
        labelColor: const Color(0xFF2E7D8F),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        isScrollable: true,
        tabs: _dietTimes.map((time) => Tab(text: time['title'].toString())).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header Section
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                // Background image with overlay
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
                // AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Day ${widget.dayNum} Meals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // Circular Icon and Title
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 50,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Meal Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          _isLoadingTabs
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D8F)))
              : _buildMealsTabBar(),
          // Content
          _isLoadingTabs
              ? const SizedBox.shrink()
              : Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _dietTimes.map((time) {
                      final dietTimeId = time['id'] as int;
                      final tabTitle = time['title'] as String;
                      return FutureBuilder<List<dynamic>>(
                        future: _dietController.fetchDietMeals(
                          day: widget.dayNum,
                          dietTime: dietTimeId,
                          dietId: widget.dietId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D8F)));
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  const Text('Unable to load meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('${snapshot.error}', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                                ],
                              ),
                            );
                          }
                          final meals = snapshot.data;
                          if (meals == null || meals.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.no_food, size: 80, color: Colors.grey),
                                  SizedBox(height: 20),
                                  Text('No Meals Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  SizedBox(height: 8),
                                  Text('No meals for this time.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: meals.length,
                            itemBuilder: (ctx, idx) {
                              final meal = meals[idx];
                              final mealTitle = meal['title'] ?? '';
                              final mealDesc = meal['description'] ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.fastfood, color: Color(0xFF2E7D8F), size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            mealTitle,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mealDesc,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _setReminder,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D8F),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: const Icon(Icons.alarm),
                                        label: const Text('Set A Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
