import 'package:flutter/material.dart';
import 'MyMealsPage.dart';
import '../../controller/diet_controller.dart';

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
      // We'll replicate the same style: background + top bar
      body: Stack(
        children: [
          // Top background
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
          // Lotus icon
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
          // AppBar
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
          // Content (List of Days)
          Positioned.fill(
            top: 240,
            child: FutureBuilder<List<dynamic>>(
              future: _futureDays,
              builder: (context, snapshot) {
                // Loading indicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Data loaded
                final days = snapshot.data;
                if (days == null || days.isEmpty) {
                  return const Center(
                    child: Text(
                      "No days found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Display the days in a list
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: days.length,
                  itemBuilder: (ctx, idx) {
                    // The API returns objects like {"day": 1}
                    final dayNum = days[idx]['day'] ?? 'N/A';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          "Day $dayNum",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // Go to MyMealsPage (pass day number)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MyMealsPage(dayNum:dayNum, dietId:widget.diet['id'] ,),
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
