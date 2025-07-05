import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';
import 'package:get/get.dart';

class SpecialOffersController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var offers = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final offersData = await _fetchOffers();
      // Parse the HTML content and extract offers if needed
      offers.assignAll([offersData]); // For now, just store the HTML content
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Fetches the special offers HTML content from the API.
  Future<String> _fetchOffers() async {
    String? bearerToken= await getAccessToken();
    const String url = 'https://portal.ahmed-hussain.com/api/patient/offers';
    final response = await http.get(Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        // Return the HTML content from the 'data' key.
        return jsonResponse['data'].toString();
      } else {
        throw Exception('API Error: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load offers. Status code: ${response.statusCode}');
    }
  }
}
