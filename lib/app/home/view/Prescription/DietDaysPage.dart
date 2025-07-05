import 'package:flutter/material.dart';
import 'MyMealsPage.dart';
import '../../controller/diet_controller.dart';
import '../../../../general/consts/colors.dart';

class DietDaysPage extends StatefulWidget {
  // Note: We use Map<String, dynamic> to include 'id' as an int
  final Map<String, dynamic> diet;

  const DietDaysPage(this.diet, {Key? key}) : super(key: key);

  @override
  _DietDaysPageState createState() => _DietDaysPageState();
}

class _DietDaysPageState extends State<DietDaysPage> {
  late Future<List<dynamic>> _futureDays;
  final _dietController = DietController();

  @override
  void initState() {
    super.initState();
    // Extract the diet ID from the passed diet map
    final dietId = widget.diet['id'] ?? 0;
    // Fetch the days for this diet ID
    _futureDays = _dietController.fetchDietDays(dietId);
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
                    title: const Text(
                      'Diet Days',
                      style: TextStyle(
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
                          Icons.calendar_today,
                          size: 50,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select a Day',
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
          // Content
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureDays,
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
                        const Text('Unable to load days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                final days = snapshot.data;
                if (days == null || days.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('No Days Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('No days for this diet.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: days.length,
                  itemBuilder: (ctx, idx) {
                    final dayNum = days[idx]['day'] ?? 'N/A';
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
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D8F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today, color: Color(0xFF2E7D8F), size: 24),
                        ),
                        title: Text(
                          "Day $dayNum",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MyMealsPage(dayNum: dayNum, dietId: widget.diet['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
