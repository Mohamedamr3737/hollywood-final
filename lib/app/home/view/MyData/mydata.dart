import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/MyDataController.dart';
import 'MydataDetailspage.dart';
import '../../../auth/controller/token_controller.dart';

/// -----------------------------------------
/// MyDataPage displays background, a logo and the list of categories
/// -----------------------------------------
class MyDataPage extends StatelessWidget {
  const MyDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    checkLoginStatus();
    final MyDataController controller = MyDataController();

    return Scaffold(
      body: FutureBuilder<List<Category>>(
        future: controller.fetchCategories(),
        builder: (context, snapshot) {
          // While waiting for the API call, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display error if any
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Once data is available, show the UI with categories
          else if (snapshot.hasData) {
            List<Category> categories = snapshot.data!;
            return Stack(
              children: [
                // (A) Background at top
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Image.network(
                        'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
                // (B) Positioned lotus circle
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
                // (C) Custom app bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.orangeAccent),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      "My Data",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // (D) Content - list of categories
                Positioned.fill(
                  top: 240, // space under the circle
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      Category category = categories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Navigate to details page (you can update this as needed)
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => InBodyDetailPage(
                                        categoryId: category.id),
                                  ),
                                );
                              },
                              child: const Text(
                                "VIEW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}

/// -----------------------------------------
/// CategoryDetailPage shows details of the selected category.
/// -----------------------------------------
// class CategoryDetailPage extends StatelessWidget {
//   final Category category;
//   const CategoryDetailPage({super.key, required this.category});
//
//   @override
//   Widget build(BuildContext context) {
//     // Replace this dummy detail page with your actual details view.
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(category.title),
//       ),
//       body: Center(
//         child: Text(
//           'Details for ${category.title}',
//           style: const TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
