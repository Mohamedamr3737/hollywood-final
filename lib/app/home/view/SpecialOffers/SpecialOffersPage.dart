// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../controller/SpecialOffersController.dart';
import '../../../auth/controller/token_controller.dart';

class SpecialOffersPage extends StatefulWidget {
  const SpecialOffersPage({super.key});

  @override
  State<SpecialOffersPage> createState() => _SpecialOffersPageState();
}

class _SpecialOffersPageState extends State<SpecialOffersPage> {
  late Future<List<Offer>> _futureOffers;
  final SpecialOffersController _controller = SpecialOffersController();

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
    _futureOffers = _controller.fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Offer>>(
        future: _futureOffers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Full-page loading indicator while waiting for the API call.
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Stack(
              children: [
                // Background image with AppBar overlay
                Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60), // Space for the circular logo
                  ],
                ),
                // Positioned Circular Logo
                Positioned(
                  top: 210,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                        ),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                // Custom AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: const Text(
                      "Special Offers",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // Error state content
                Positioned.fill(
                  top: 200, // Below the background image and logo
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 80),
                          // Error state icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[50],
                              border: Border.all(
                                color: Colors.red[200]!,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Error state title
                          Text(
                            "Unable to Load Offers",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Error state description
                          Text(
                            "There was a problem loading the special offers. Please check your internet connection and try again.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Retry button
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _futureOffers = _controller.fetchOffers();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Try Again"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            final offers = snapshot.data!;
            
            // Check if offers list is empty
            if (offers.isEmpty) {
              return Stack(
                children: [
                  // Background image with AppBar overlay
                  Column(
                    children: [
                      Container(
                        height: 250,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60), // Space for the circular logo
                    ],
                  ),
                  // Positioned Circular Logo
                  Positioned(
                    top: 210,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                          ),
                          fit: BoxFit.contain,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Custom AppBar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      title: const Text(
                        "Special Offers",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  // Empty state content
                  Positioned.fill(
                    top: 200, // Below the background image and logo
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),
                            // Empty state icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange[50],
                                border: Border.all(
                                  color: Colors.orange[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                size: 60,
                                color: Colors.orange[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Empty state title
                            Text(
                              "No Special Offers Available",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            // Empty state description
                            Text(
                              "Check back later for exciting offers and promotions!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            // Refresh button
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _futureOffers = _controller.fetchOffers();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Refresh"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // If offers exist, show the normal layout
            return Stack(
              children: [
                // Background image with AppBar overlay
                Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60), // Space for the circular logo
                  ],
                ),
                // Positioned Circular Logo
                Positioned(
                  top: 210,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                        ),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                // Custom AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: const Text(
                      "Special Offers",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                // Content: display the offers list
                Positioned.fill(
                  top: 200, // Below the background image and logo
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 80),

                        const SizedBox(height: 20),
                        // Build a list of OfferCards from the fetched data
                        for (var offer in offers)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: OfferCard(offer: offer),
                          ),
                      ],
                    ),
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

class OfferCard extends StatelessWidget {
  final Offer offer;
  const OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      offer.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Short description
                      if (offer.shortDescription.isNotEmpty)
                        Text(
                          offer.shortDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      // Status and button row
                      Row(
                        children: [
                          // Offer Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: offer.registered ? Colors.green[100] : Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: offer.registered ? Colors.green : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  offer.registered ? Icons.check_circle : Icons.local_offer,
                                  color: offer.registered ? Colors.green[700] : Colors.orange[700],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  offer.registered ? "Registered" : "Available",
                                  style: TextStyle(
                                    color: offer.registered ? Colors.green[700] : Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // "Read More" button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.grey[800]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => OfferDetailPage(offer: offer));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: const Text(
                                'Read More',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfferDetailPage extends StatelessWidget {
  final Offer offer;

  const OfferDetailPage({Key? key, required this.offer}) : super(key: key);

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
    // Debug: Print the offer data to see what we're working with
    print("Offer Body: ${offer.body}");
    print("Offer Description: ${offer.shortDescription}");
    print("Offer Registered: ${offer.registered}");
    
    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: offer.body != null && offer.body!.isNotEmpty && isIframeOnly(offer.body!)
          ? _buildIframeContent()
          : _buildRegularContent(),
    );
  }

  Widget _buildIframeContent() {
    final iframeUrl = extractIframeUrl(offer.body!);
    if (iframeUrl == null) {
      return const Center(
        child: Text("Unable to load offer content"),
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
          if (offer.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                offer.image,
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
            offer.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Offer Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: offer.registered ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: offer.registered ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  offer.registered ? Icons.check_circle : Icons.local_offer,
                  color: offer.registered ? Colors.green[700] : Colors.orange[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  offer.registered ? "Registered" : "Available",
                  style: TextStyle(
                    color: offer.registered ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // HTML Content Section
          if (offer.body != null && offer.body!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Html(
                data: offer.body!,
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
                    "No detailed content available for this offer.",
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
