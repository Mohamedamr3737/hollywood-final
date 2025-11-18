import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:s_medi/general/consts/consts.dart';

// If you want to parse HTML in ServiceDetailPage, import flutter_html there.

// Example detail page that can parse HTML in the 'body' field.
class ServiceDetailPage extends StatelessWidget {
  final Service service;

  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

  // Helper method to extract iframe URL from HTML
  String? extractIframeUrl(String html) {
    final RegExp iframeRegex = RegExp(r'<iframe[^>]+src="([^"]+)"');
    final Match? match = iframeRegex.firstMatch(html);
    return match?.group(1);
  }

  // Helper method to check if content is just an iframe
  bool isIframeOnly(String html) {
    final cleanHtml = html.trim();
    return cleanHtml.startsWith('<iframe') && cleanHtml.endsWith('</iframe>');
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print the service data to see what we're working with
    print("Service Body: ${service.body}");
    print("Service Details: ${service.details}");
    print("Service Description: ${service.description}");
    
    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: service.body != null && service.body!.isNotEmpty && isIframeOnly(service.body!)
          ? _buildIframeContent()
          : _buildRegularContent(),
    );
  }

  Widget _buildIframeContent() {
    final iframeUrl = extractIframeUrl(service.body!);
    if (iframeUrl == null) {
      return const Center(
        child: Text("Unable to load service content"),
      );
    }

    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading progress
            },
            onPageStarted: (String url) {
              print("Page started loading: $url");
            },
            onPageFinished: (String url) {
              print("Page finished loading: $url");
            },
            onWebResourceError: (WebResourceError error) {
              print("WebView error: ${error.description}");
            },
          ),
        )
        ..loadRequest(Uri.parse(iframeUrl)),
    );
  }

  Widget _buildRegularContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Image
          if (service.imagePath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                service.imagePath,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Title
          Text(
            service.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // HTML Content Section
          if (service.body != null && service.body!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Html(
                data: service.body!,
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    color: Colors.black87,
                    lineHeight: LineHeight(1.5),
                  ),
                  "p": Style(
                    fontSize: FontSize(16),
                    color: Colors.black87,
                    lineHeight: LineHeight(1.5),
                    margin: Margins.only(bottom: 12),
                  ),
                  "h1": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    margin: Margins.only(bottom: 16),
                  ),
                  "h2": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    margin: Margins.only(bottom: 14),
                  ),
                  "h3": Style(
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    margin: Margins.only(bottom: 12),
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "li": Style(
                    fontSize: FontSize(16),
                    color: Colors.black87,
                    lineHeight: LineHeight(1.5),
                    margin: Margins.only(bottom: 4),
                  ),
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    "No detailed content available for this service.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
/// Model class for each service item.
class Service {
  final String title;
  final String description;
  final String imagePath;
  final String details;
  final List<String>? detailImages;
  final String? body; // Add 'body' field to hold HTML or detailed text.

  Service({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.details,
    this.detailImages,
    this.body,
  });

  /// Factory constructor to parse JSON from the API.
  factory Service.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON to see what fields are available
    print("Raw Service JSON: $json");
    
    // Try different possible field names for the body/content
    String bodyContent = "";
    if (json["body"] != null) {
      bodyContent = json["body"].toString();
    } else if (json["content"] != null) {
      bodyContent = json["content"].toString();
    } else if (json["description"] != null) {
      bodyContent = json["description"].toString();
    } else if (json["details"] != null) {
      bodyContent = json["details"].toString();
    }
    
    return Service(
      title: json["title"] ?? json["name"] ?? "Untitled Service",
      description: json["short_description"] ?? json["summary"] ?? json["description"] ?? "",
      imagePath: json["image"] ?? json["image_url"] ?? json["photo"] ?? "",
      details: json["details"] ?? json["short_description"] ?? "",
      detailImages: [],
      body: bodyContent,
    );
  }
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool isLoading = false;
  String errorMessage = "";
  List<Service> services = [];

  /// Fetch services from the API.
  Future<void> fetchServices() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("${ApiConfig.baseUrl}/api/patient/pages/Service");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true) {
          // data["data"] should be a list of service items
          final List<dynamic> rawServices = data["data"];
          services = rawServices.map((jsonItem) => Service.fromJson(jsonItem)).toList();
          errorMessage = '';
        } else {
          errorMessage = data["message"] ?? "Failed to fetch services.";
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
  void initState() {
    super.initState();
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 16),
          const Text(
            "Our Features & Services",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Build a list of ServiceCards from the fetched data
          for (var service in services)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ServiceCard(service: service),
            ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;
  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circle image
            ClipOval(
              child: Image.network(
                service.imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 100);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              service.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Short description
            Text(
              service.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // "Read More" button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                // Pass the entire service object to detail page
                Get.to(() => ServiceDetailPage(service: service));
              },
              child: const Text('Read More', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: const ServicesPage(),
  ));
}
