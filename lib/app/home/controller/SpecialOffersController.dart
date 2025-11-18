import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';
import 'package:s_medi/general/consts/consts.dart';

/// Model class for each offer item.
class Offer {
  final int id;
  final String title;
  final String image;
  final String type;
  final String shortDescription;
  final String? body;
  final bool registered;
  final String startAt;
  final String endAt;

  Offer({
    required this.id,
    required this.title,
    required this.image,
    required this.type,
    required this.shortDescription,
    this.body,
    required this.registered,
    required this.startAt,
    required this.endAt,
  });

  /// Factory constructor to parse JSON from the API.
  factory Offer.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON to see what fields are available
    print("Raw Offer JSON: $json");
    
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
    
    return Offer(
      id: json["id"] ?? 0,
      title: json["title"] ?? "Untitled Offer",
      image: json["image"] ?? json["image_url"] ?? json["photo"] ?? "",
      type: json["type"] ?? "offer",
      shortDescription: json["short_description"] ?? json["summary"] ?? json["description"] ?? "",
      body: bodyContent,
      registered: json["registered"] ?? false,
      startAt: json["start_at"] ?? "",
      endAt: json["end_at"] ?? "",
    );
  }
}

class SpecialOffersController {
  List<Offer> offers = [];
  String errorMessage = "";

  /// Fetches the special offers from the API.
  Future<List<Offer>> fetchOffers() async {
    try {
      // Get the access token
      String? bearerToken = await getAccessToken();
      final String url = '${ApiConfig.baseUrl}/api/patient/offers';

      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true) {
          // Handle different response formats for empty data
          dynamic data = jsonResponse['data'];
          List<dynamic> rawOffers = [];
          
          if (data is List) {
            rawOffers = data;
          } else if (data is Map) {
            // If data is a Map (object), check if it has any array properties
            if (data.containsKey('offers') && data['offers'] is List) {
              rawOffers = data['offers'];
            } else if (data.containsKey('items') && data['items'] is List) {
              rawOffers = data['items'];
            } else {
              // If it's an empty object or doesn't contain arrays, treat as empty
              rawOffers = [];
            }
          } else {
            // If data is null or other type, treat as empty
            rawOffers = [];
          }
          
          offers = rawOffers.map((jsonItem) => Offer.fromJson(jsonItem)).toList();
          errorMessage = '';
          return offers;
        } else {
          errorMessage = jsonResponse['message'] ?? "Failed to fetch offers.";
          throw Exception(errorMessage);
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
        throw Exception(errorMessage);
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
      throw Exception(errorMessage);
    }
  }
}
