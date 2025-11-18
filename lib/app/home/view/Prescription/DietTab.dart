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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final diets = snapshot.data;
        if (diets == null || diets.isEmpty) {
          return const Center(
            child: Text(
              "No Diet Prescriptions",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Adjust the color if needed to match your exact brand shade
                  color: const Color(0xFFFEB63B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Doctor" label
                    const Text(
                      "Doctor",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    // Actual doctor name in bold
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // "Date" label
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    // Actual date in bold
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
