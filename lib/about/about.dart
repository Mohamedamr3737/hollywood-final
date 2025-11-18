import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:s_medi/general/consts/consts.dart';

/// A simple model for the About item.
class AboutItem {
  final int id;
  final String title;
  final String image;
  final String shortDescription;
  final String body;

  AboutItem({
    required this.id,
    required this.title,
    required this.image,
    required this.shortDescription,
    required this.body,
  });

  factory AboutItem.fromJson(Map<dynamic, dynamic> json) {
    return AboutItem(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      shortDescription: json["short_description"] ?? "",
      body: json["body"] ?? "",
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  AboutItem? aboutItem;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAboutItem();
  }

  Future<void> _fetchAboutItem() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("${ApiConfig.baseUrl}/api/patient/pages/About");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true) {
          // If data is a single object, parse it directly
          // If data might be a list, you can adapt as needed
          final data = jsonResponse["data"];
          if (data is Map) {
            aboutItem = AboutItem.fromJson(data);
          } else {
            // Fallback if the API returns a list unexpectedly
            errorMessage = "Unexpected data format.";
          }
        } else {
          errorMessage = jsonResponse["message"] ?? "Failed to fetch about info.";
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // While loading, show a spinner
    if (isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If there's an error or no item, show a message
    if (aboutItem == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: Center(
          child: Text(
            errorMessage.isNotEmpty ? errorMessage : "No about data found.",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Otherwise, show the about data
    return Scaffold(
      // Transparent AppBar to overlay the curved header
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.transparent,
        elevation: 0,

        centerTitle: true,
      ),
      extendBodyBehindAppBar: true, // So the app bar floats over the header
      body: Stack(
        children: [
          // Curved header background
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: 300,
              color: Colors.orangeAccent,
            ),
          ),

          // Main content scroll view
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      aboutItem!.image,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  aboutItem!.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Short description
                Text(
                  aboutItem!.shortDescription,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),

                // Parse the HTML body
                Html(
                  data: aboutItem!.body,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      color: Colors.black87,
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom clipper to create a curved header shape
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Creates a simple curved shape for the header
    Path path = Path();
    path.lineTo(0, size.height - 50);
    // Quadratic bezier curve for a smooth shape
    path.quadraticBezierTo(
      size.width / 2, // control point x
      size.height,    // control point y
      size.width,     // end point x
      size.height - 50, // end point y
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

void main() {
  runApp(const MaterialApp(
    home: AboutPage(),
    debugShowCheckedModeBanner: false,
  ));
}
