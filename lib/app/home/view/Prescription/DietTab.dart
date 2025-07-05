// diet_tab.dart
import 'package:flutter/material.dart';
import '../../controller/diet_controller.dart';
import 'DietDaysPage.dart';

class DietTab extends StatefulWidget {
  const DietTab({Key? key}) : super(key: key);

  @override
  _DietTabState createState() => _DietTabState();
}

class _DietTabState extends State<DietTab> {
  late Future<List<dynamic>> _futureDiets;
  late DietController _dietController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with your API endpoint.
    _dietController = DietController();
    _futureDiets = _dietController.fetchDietPlans();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureDiets,
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
                const Text('Unable to load diets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('${snapshot.error}', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        final diets = snapshot.data;
        if (diets == null || diets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text('No Diet Prescriptions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Your diet prescriptions will appear here', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: diets.length,
          itemBuilder: (ctx, index) {
            final diet = diets[index];
            final date = diet['date'] ?? '';
            final doctorName = diet['doctor']?['name'] ?? 'Unknown Doctor';
            return GestureDetector(
              onTap: () {
                // Navigate to the DietDaysPage passing the full diet data
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DietDaysPage(diet),
                  ),
                );
              },
              child: Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu, color: Color(0xFF2E7D8F), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Doctor', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
