import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/diet_controller.dart';
import 'package:s_medi/general/services/alert_service.dart';

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
      AlertService.success(context, "Reminder set at ${pickedTime.format(context)}");
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
      color: const Color(0xFF000610),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.orangeAccent,
        labelColor: Colors.orangeAccent,
        unselectedLabelColor: Colors.white70,
        isScrollable: true,
        tabs: _dietTimes.map((time) => Tab(text: time['title'].toString())).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // EXACT SAME UI (background, lotus icon, AppBar, etc.) from your snippet
    return Scaffold(
      body: Stack(
        children: [
          // top background
          Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // lotus
          Positioned(
            top: 110,
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
          // appBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "My Meals",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // content
          Positioned.fill(
            top: 260,
            child: _isLoadingTabs
            // While loading the meal times, show a spinner
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                // Tab bar at the top
                _buildMealsTabBar(),
                // For each tab, fetch the meals from the API
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _dietTimes.map((time) {
                      final dietTimeId = time['id'] as int;
                      final tabTitle = time['title'] as String;

                      // Use a FutureBuilder to fetch the meals for each tab
                      return FutureBuilder<List<dynamic>>(
                        future: _dietController.fetchDietMeals(
                          day: widget.dayNum,
                          dietTime: dietTimeId,
                          dietId: widget.dietId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final meals = snapshot.data ?? [];
                          if (meals.isEmpty) {
                            return Center(child: Text("No meals for $tabTitle."));
                          }
                          // Build a list of meal cards
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: meals.length,
                            itemBuilder: (ctx, idx) {
                              final meal = meals[idx];
                              final title = meal['title'] ?? '';
                              final description = meal['description'] ?? '';
                              final calories = meal['calories']?.toString() ?? '0';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  title: Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Calories\n$calories",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                // "Set A Reminder" button at bottom
                SafeArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _setReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Set A Reminder",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
