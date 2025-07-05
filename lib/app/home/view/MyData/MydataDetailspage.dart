import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/MyDataController.dart';

class InBodyDetailPage extends StatefulWidget {
  // Accept categoryId so this page can be used for any category.
  final int categoryId;

  const InBodyDetailPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<InBodyDetailPage> createState() => _InBodyDetailPageState();
}

class _InBodyDetailPageState extends State<InBodyDetailPage> {
  late Future<DataResponse> _futureData;
  late MyDataController _controller;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = MyDataController();
    _futureData = _controller.fetchData(widget.categoryId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Animate PageView to the tapped index
  void _goToIndex(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DataResponse>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for API data, show a full-page loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final dataResponse = snapshot.data!;
            final List<DataItem> myData = dataResponse.myData;

            return Stack(
              children: [
                // (A) Top background image
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Image.network(
                        'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                        fit: BoxFit.cover,
                        // Show a spinner while loading the background image
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
                // (B) Positioned lotus circle
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
                // (C) Custom AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.orangeAccent,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      "In Body",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // (D) Page Content
                Positioned.fill(
                  top: 240,
                  child: Column(
                    children: [
                      // 1) PageView with images from myData
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: myData.length,
                          itemBuilder: (context, index) {
                            final imageUrl = myData[index].image;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (ctx, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(child: Text("Image not found")),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 2) Dots indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(myData.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 12 : 8,
                            height: isActive ? 12 : 8,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.orangeAccent : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      // 3) Horizontal list of circle images with dates
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: myData.length,
                          separatorBuilder: (context, _) => const SizedBox(width: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final imageUrl = myData[index].image;
                            final date = myData[index].date;
                            final isSelected = index == _currentPage;

                            return GestureDetector(
                              onTap: () => _goToIndex(index),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Circle image thumbnail with loading indicator
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.orangeAccent : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (ctx, error, stackTrace) => Container(
                                          color: Colors.grey[300],
                                          alignment: Alignment.center,
                                          child: const Text("Not found", style: TextStyle(fontSize: 10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Date label
                                  Text(
                                    date,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}
