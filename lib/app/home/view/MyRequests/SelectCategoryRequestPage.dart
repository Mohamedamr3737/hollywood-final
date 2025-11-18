// select_category_page.dart
import 'package:flutter/material.dart';
import '../../controller/requests_controller.dart';
import 'request.dart'; // MyRequestsPage
import '../../../auth/controller/token_controller.dart';

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({Key? key}) : super(key: key);

  @override
  State<SelectCategoryPage> createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  late Future<List<dynamic>> _futureCategories;
  final RequestsController _requestsController = RequestsController();

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
    // Fetch the categories when the page is created
    _futureCategories = _requestsController.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // (A) Background sparkly image
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
          // (B) Circle lotus icon
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
          // (C) Custom AppBar
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
                "Select Category",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (D) Content: The category cards
          Positioned.fill(
            top: 250,
            child: FutureBuilder<List<dynamic>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                // 1) Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2) Error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // 3) Data loaded
                final categories = snapshot.data;
                if (categories == null || categories.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Categories Found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Each item is { "id": 1, "title": "Appointment" }
                return ListView.builder(
                  itemCount: categories.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (ctx, index) {
                    final catItem = categories[index];
                    final catId = catItem['id']?? '0';
                    final catTitle = catItem['title'] ?? 'Unknown';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          catTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to MyRequestsPage, passing the category title or ID
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyRequestsPage(
                                  category: catId,
                                  // or pass the catId if your next page needs it
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "VIEW",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
